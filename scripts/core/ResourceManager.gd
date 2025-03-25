extends Node

# Signals
signal resource_loaded(resource_path, resource)
signal resource_load_failed(resource_path, error)
signal resource_unloaded(resource_path)
signal memory_warning

# Constants
const MEMORY_WARNING_THRESHOLD: int = 500 * 1024 * 1024  # 500 MB

# Cache settings
@export var max_cache_size: int = 100  # Maximum number of resources to cache
@export var cache_timeout: float = 300.0  # Seconds before unused resources are unloaded

# Resource cache
# Dictionary format: { resource_path: { resource: Resource, last_accessed: float, size: int } }
var _resource_cache: Dictionary = {}

# Queue for asynchronous loading
var _load_queue: Array[Dictionary] = []

# Statistics
var _total_cache_size: int = 0
var _cache_hits: int = 0
var _cache_misses: int = 0
var _resources_loaded: int = 0
var _resources_unloaded: int = 0

# Current asynchronous loading operation
var _current_load_operation: Dictionary = {}
var _is_loading: bool = false

# Called when the node enters the scene tree
func _ready() -> void:
	print("ResourceManager initialized")
	# Start the cache cleanup timer
	var timer = Timer.new()
	timer.wait_time = 60.0  # Check the cache every minute
	timer.autostart = true
	timer.timeout.connect(_cleanup_cache)
	add_child(timer)

# Process the load queue
func _process(_delta: float) -> void:
	_process_load_queue()

# Synchronously load a resource with caching
# Returns the loaded resource, or null if loading failed
func load_resource(path: String, use_sub_threads: bool = false, cache: bool = true) -> Resource:
	# Check if resource is already cached
	if _resource_cache.has(path):
		var cache_entry = _resource_cache[path]
		cache_entry.last_accessed = Time.get_unix_time_from_system()
		_cache_hits += 1
		return cache_entry.resource
	
	_cache_misses += 1
	
	# Attempt to load the resource
	if not ResourceLoader.exists(path):
		push_error("Resource does not exist: " + path)
		resource_load_failed.emit(path, "Resource does not exist")
		return null
	
	var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE if cache else ResourceLoader.CACHE_MODE_IGNORE)
	
	if resource == null:
		push_error("Failed to load resource: " + path)
		resource_load_failed.emit(path, "Failed to load resource")
		return null
	
	_resources_loaded += 1
	
	# Cache the resource if caching is enabled
	if cache:
		_cache_resource(path, resource)
	
	resource_loaded.emit(path, resource)
	return resource

# Asynchronously load a resource
# The callback will be called with the loaded resource, or null if loading failed
func load_resource_async(path: String, callback: Callable, cache: bool = true) -> void:
	# Check if resource is already cached
	if _resource_cache.has(path):
		var cache_entry = _resource_cache[path]
		cache_entry.last_accessed = Time.get_unix_time_from_system()
		_cache_hits += 1
		callback.call(cache_entry.resource)
		return
	
	_cache_misses += 1
	
	# Add to the load queue
	_load_queue.append({
		"path": path,
		"callback": callback,
		"cache": cache
	})

# Unload a resource from the cache
# Returns true if the resource was in the cache and was unloaded
func unload_resource(path: String) -> bool:
	if not _resource_cache.has(path):
		return false
	
	var cache_entry = _resource_cache[path]
	_total_cache_size -= cache_entry.size
	_resource_cache.erase(path)
	_resources_unloaded += 1
	
	resource_unloaded.emit(path)
	return true

# Preload a list of resources asynchronously
# The callback will be called once all resources are loaded with an array of loaded resources
func preload_resources(paths: Array[String], callback: Callable, cache: bool = true) -> void:
	var loaded_resources: Array = []
	var resources_to_load = paths.size()
	
	if resources_to_load == 0:
		callback.call(loaded_resources)
		return
	
	# Store preload tracking info
	var preload_info = {
		"loaded_resources": loaded_resources,
		"resources_to_load": resources_to_load,
		"callback": callback
	}
	
	# Queue all resources to load
	for path in paths:
		var resource_callback = _on_preload_resource_loaded.bind(preload_info)
		load_resource_async(path, resource_callback, cache)

# Clear the entire resource cache
func clear_cache() -> void:
	_resource_cache.clear()
	_total_cache_size = 0
	_resources_unloaded = 0
	print("Resource cache cleared")

# Get cache statistics
func get_cache_stats() -> Dictionary:
	return {
		"cache_size": _resource_cache.size(),
		"total_cache_size_bytes": _total_cache_size,
		"cache_hits": _cache_hits,
		"cache_misses": _cache_misses,
		"resources_loaded": _resources_loaded,
		"resources_unloaded": _resources_unloaded,
		"load_queue_size": _load_queue.size(),
		"is_loading": _is_loading
	}

# PRIVATE METHODS

# Helper for preload tracking
func _on_preload_resource_loaded(resource: Resource, preload_info: Dictionary) -> void:
	preload_info.loaded_resources.append(resource)
	preload_info.resources_to_load -= 1
	
	if preload_info.resources_to_load == 0:
		preload_info.callback.call(preload_info.loaded_resources)

# Process the resource load queue
func _process_load_queue() -> void:
	if _load_queue.empty() or _is_loading:
		return
	
	# Start the next loading operation
	_current_load_operation = _load_queue.pop_front()
	var path = _current_load_operation.path
	
	if not ResourceLoader.exists(path):
		push_error("Resource does not exist: " + path)
		_current_load_operation.callback.call(null)
		resource_load_failed.emit(path, "Resource does not exist")
		return
	
	_is_loading = true
	ResourceLoader.load_threaded_request(path, "", _current_load_operation.cache)
	
	# Create a timer to poll the loading status
	var timer = Timer.new()
	timer.wait_time = 0.05  # Check every 50ms
	timer.autostart = true
	timer.timeout.connect(_check_load_status.bind(timer))
	add_child(timer)

# Check the status of the current load operation
func _check_load_status(timer: Timer) -> void:
	var path = _current_load_operation.path
	var status = ResourceLoader.load_threaded_get_status(path)
	
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			# Resource is loaded
			var resource = ResourceLoader.load_threaded_get(path)
			_resources_loaded += 1
			
			if _current_load_operation.cache:
				_cache_resource(path, resource)
			
			_current_load_operation.callback.call(resource)
			resource_loaded.emit(path, resource)
			
			# Clean up
			timer.queue_free()
			_is_loading = false
		
		ResourceLoader.THREAD_LOAD_FAILED:
			# Loading failed
			push_error("Failed to load resource: " + path)
			_current_load_operation.callback.call(null)
			resource_load_failed.emit(path, "Failed to load resource")
			
			# Clean up
			timer.queue_free()
			_is_loading = false
		
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			# Invalid resource
			push_error("Invalid resource: " + path)
			_current_load_operation.callback.call(null)
			resource_load_failed.emit(path, "Invalid resource")
			
			# Clean up
			timer.queue_free()
			_is_loading = false
		
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Still loading, continue polling
			pass

# Cache a resource
func _cache_resource(path: String, resource: Resource) -> void:
	# Check if the cache is full and needs to be trimmed
	if _resource_cache.size() >= max_cache_size:
		_trim_cache()
	
	# Estimate resource size (basic estimation, could be improved)
	var size: int = _estimate_resource_size(resource)
	
	# Add to cache
	_resource_cache[path] = {
		"resource": resource,
		"last_accessed": Time.get_unix_time_from_system(),
		"size": size
	}
	
	_total_cache_size += size
	
	# Check if we need to emit a memory warning
	if _total_cache_size > MEMORY_WARNING_THRESHOLD:
		memory_warning.emit()
		print("Memory warning: Cache size exceeds threshold")

# Estimate the memory size of a resource
func _estimate_resource_size(resource: Resource) -> int:
	# This is a basic estimation and could be improved
	var size: int = 1024  # Base size for any resource
	
	# Different resource types have different memory footprints
	if resource is Texture2D:
		var texture: Texture2D = resource
		size = texture.get_width() * texture.get_height() * 4  # RGBA, 4 bytes per pixel
	elif resource is AudioStream:
		size = 500 * 1024  # Rough estimate for audio streams
	elif resource is PackedScene:
		size = 2 * 1024 * 1024  # Rough estimate for scenes
	elif resource is Mesh:
		size = 1 * 1024 * 1024  # Rough estimate for meshes
	
	return size

# Clean up the cache by removing old entries
func _cleanup_cache() -> void:
	var current_time = Time.get_unix_time_from_system()
	var paths_to_remove: Array = []
	
	# Find resources that haven't been accessed in a while
	for path in _resource_cache:
		var cache_entry = _resource_cache[path]
		if current_time - cache_entry.last_accessed > cache_timeout:
			paths_to_remove.append(path)
	
	# Remove the old resources
	for path in paths_to_remove:
		unload_resource(path)
	
	if paths_to_remove.size() > 0:
		print("Cleaned up " + str(paths_to_remove.size()) + " unused resources from cache")

# Trim the cache to stay within the max size limit
func _trim_cache() -> void:
	# Sort resources by last access time (oldest first)
	var entries = _resource_cache.keys()
	entries.sort_custom(func(a, b): 
		return _resource_cache[a].last_accessed < _resource_cache[b].last_accessed
	)
	
	# Remove the oldest resources until we're under the limit
	var resources_to_remove = entries.size() - max_cache_size + 10  # Remove a few extra to avoid frequent trimming
	for i in range(min(resources_to_remove, entries.size())):
		unload_resource(entries[i])
	
	print("Trimmed cache, removed " + str(resources_to_remove) + " resources")
