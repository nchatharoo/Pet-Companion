class_name HouseManager
extends Node3D

# Signal emitted when the house is fully loaded and ready
signal house_ready

# References to house components
@onready var house_layout = $HouseLayout
@onready var navigation = $Navigation

# Dictionary to track interactable objects in the house
var interactable_objects = {}

func _ready():
	# Wait for house to be ready
	if house_layout:
		house_layout.house_ready.connect(_on_house_ready)
	else:
		push_error("HouseManager: Missing HouseLayout node")

func _on_house_ready():
	# Make sure all components are properly set up
	_setup_navigation()
	_register_interactable_objects()
	
	# Let the rest of the game know the house is ready
	emit_signal("house_ready")

func _setup_navigation():
	# Wait a frame to ensure all geometry is loaded
	await get_tree().process_frame
	
	if navigation:
		# Bake the navigation mesh
		var nav_mesh = NavigationMesh.new()
		nav_mesh.cell_size = 0.3
		nav_mesh.cell_height = 0.2
		navigation.navigation_mesh = nav_mesh
		navigation.bake_navigation_mesh()
		
		print("Navigation mesh baked successfully")
	else:
		push_error("HouseManager: Missing Navigation node")

func _register_interactable_objects():
	# Find all interactable objects in the house
	var interactables = get_tree().get_nodes_in_group("interactable")
	
	for obj in interactables:
		if obj.has_method("get_interaction_type"):
			var type = obj.get_interaction_type()
			if not interactable_objects.has(type):
				interactable_objects[type] = []
			interactable_objects[type].append(obj)
	
	print("Registered ", interactables.size(), " interactable objects")

func get_nearest_interactable(position: Vector3, type: String) -> Node3D:
	# Find the nearest interactable object of a specific type
	if not interactable_objects.has(type) or interactable_objects[type].size() == 0:
		return null
		
	var nearest = null
	var nearest_distance = INF
	
	for obj in interactable_objects[type]:
		var distance = position.distance_to(obj.global_position)
		if distance < nearest_distance:
			nearest = obj
			nearest_distance = distance
			
	return nearest

func get_random_position_in_room(room_name: String) -> Vector3:
	if house_layout:
		return house_layout.get_random_position_in_room(room_name)
	return Vector3.ZERO
