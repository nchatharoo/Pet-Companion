extends Control

# Reference to the ResourceManager singleton
var resource_manager: ResourceManager

# Test resource paths - these will need to be adjusted to actual resources in the project
var test_texture_path: String = "res://assets/ui/default_icon.png"
var test_scene_path: String = "res://scenes/main/main.tscn"
var test_resources: Array[String] = [
	"res://assets/ui/default_icon.png",
	"res://scenes/main/main.tscn",
	"res://resources/default_env.tres"
]

# For tracking loading times
var loading_start_time: float = 0.0
var last_loaded_path: String = ""

func _ready() -> void:
	# Get the ResourceManager singleton
	resource_manager = get_node("/root/ResourceManager")
	
	if resource_manager == null:
		_set_result_text("ERROR: ResourceManager singleton not found. Make sure it's set up as an Autoload in Project Settings.")
		return
	
	# Connect signals from ResourceManager
	resource_manager.resource_loaded.connect(_on_resource_loaded)
	resource_manager.resource_load_failed.connect(_on_resource_load_failed)
	resource_manager.resource_unloaded.connect(_on_resource_unloaded)
	resource_manager.memory_warning.connect(_on_memory_warning)
	
	_set_result_text("ResourceManagerTest initialized. Ready to test!")
	_update_stats()
	
	# Check if test resources exist
	var all_resources_exist = true
	for path in test_resources:
		if not ResourceLoader.exists(path):
			_set_result_text("WARNING: Test resource does not exist: " + path)
			all_resources_exist = false
	
	if not all_resources_exist:
		_set_result_text("Some test resources do not exist. Please adjust the paths in the script.")

# BUTTON EVENT HANDLERS

func _on_load_sync_button_pressed() -> void:
	_set_result_text("Loading resource synchronously: " + test_texture_path)
	
	loading_start_time = Time.get_ticks_msec()
	last_loaded_path = test_texture_path
	
	var resource = resource_manager.load_resource(test_texture_path)
	
	if resource != null:
		var loading_time = Time.get_ticks_msec() - loading_start_time
		_set_result_text("Resource loaded successfully in " + str(loading_time) + "ms")
		
		# If it's a texture, display it
		if resource is Texture2D:
			var texture_rect = $VBoxContainer/TextureRect
			texture_rect.texture = resource
	else:
		_set_result_text("Failed to load resource")
	
	_update_stats()

func _on_load_async_button_pressed() -> void:
	_set_result_text("Loading resource asynchronously: " + test_texture_path)
	
	loading_start_time = Time.get_ticks_msec()
	last_loaded_path = test_texture_path
	
	resource_manager.load_resource_async(test_texture_path, _on_async_resource_loaded)
	
	# The result will be handled in the callback

func _on_unload_button_pressed() -> void:
	if last_loaded_path.is_empty():
		_set_result_text("No resource has been loaded yet")
		return
	
	_set_result_text("Unloading resource: " + last_loaded_path)
	
	var success = resource_manager.unload_resource(last_loaded_path)
	
	if success:
		_set_result_text("Resource unloaded successfully")
		
		# Clear the texture display
		var texture_rect = $VBoxContainer/TextureRect
		texture_rect.texture = null
	else:
		_set_result_text("Resource was not in the cache")
	
	_update_stats()

func _on_preload_button_pressed() -> void:
	_set_result_text("Preloading " + str(test_resources.size()) + " resources...")
	
	loading_start_time = Time.get_ticks_msec()
	
	resource_manager.preload_resources(test_resources, _on_resources_preloaded)
	
	# The result will be handled in the callback

func _on_clear_cache_button_pressed() -> void:
	_set_result_text("Clearing resource cache...")
	
	resource_manager.clear_cache()
	
	_set_result_text("Resource cache cleared")
	_update_stats()

func _on_show_stats_button_pressed() -> void:
	_update_stats()

# SIGNAL HANDLERS

func _on_resource_loaded(resource_path: String, _resource: Resource) -> void:
	print("Resource loaded: " + resource_path)

func _on_resource_load_failed(resource_path: String, error: String) -> void:
	_set_result_text("Failed to load resource: " + resource_path + "\nError: " + error)

func _on_resource_unloaded(resource_path: String) -> void:
	print("Resource unloaded: " + resource_path)

func _on_memory_warning() -> void:
	_set_result_text("WARNING: Memory usage is high. Consider clearing the cache.")

# CALLBACK HANDLERS

func _on_async_resource_loaded(resource: Resource) -> void:
	var loading_time = Time.get_ticks_msec() - loading_start_time
	
	if resource != null:
		_set_result_text("Async resource loaded successfully in " + str(loading_time) + "ms")
		
		# If it's a texture, display it
		if resource is Texture2D:
			var texture_rect = $VBoxContainer/TextureRect
			texture_rect.texture = resource
	else:
		_set_result_text("Failed to load resource asynchronously")
	
	_update_stats()

func _on_resources_preloaded(resources: Array) -> void:
	var loading_time = Time.get_ticks_msec() - loading_start_time
	
	_set_result_text("Preloaded " + str(resources.size()) + " resources in " + str(loading_time) + "ms")
	
	# If the first resource is a texture, display it
	if resources.size() > 0 and resources[0] is Texture2D:
		var texture_rect = $VBoxContainer/TextureRect
		texture_rect.texture = resources[0]
	
	_update_stats()

# UTILITY METHODS

func _set_result_text(text: String) -> void:
	$VBoxContainer/ResultsLabel.text = text

func _update_stats() -> void:
	var stats = resource_manager.get_cache_stats()
	
	var stats_text = "Cache Statistics:\n"
	stats_text += "Resources in cache: " + str(stats.cache_size) + "\n"
	stats_text += "Total cache size: " + _format_size(stats.total_cache_size_bytes) + "\n"
	stats_text += "Cache hits: " + str(stats.cache_hits) + "\n"
	stats_text += "Cache misses: " + str(stats.cache_misses) + "\n"
	stats_text += "Resources loaded: " + str(stats.resources_loaded) + "\n"
	stats_text += "Resources unloaded: " + str(stats.resources_unloaded) + "\n"
	stats_text += "Load queue size: " + str(stats.load_queue_size) + "\n"
	stats_text += "Is loading: " + str(stats.is_loading)
	
	$VBoxContainer/StatsLabel.text = stats_text

func _format_size(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1024 * 1024:
		return str(bytes / 1024.0).pad_decimals(2) + " KB"
	else:
		return str(bytes / (1024.0 * 1024.0)).pad_decimals(2) + " MB"
