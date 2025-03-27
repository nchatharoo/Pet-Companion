extends Node3D

# Test script for verifying house functionality

func _ready():
	# Get references to house components
	var house = $House
	var house_manager = house
	var house_layout = house.get_node("HouseLayout")
	
	# Connect to house ready signal
	house_manager.house_ready.connect(_on_house_ready)
	
	# Setup debug UI
	_setup_debug_ui()
	
	print("House test initialized")

func _on_house_ready():
	print("House is ready!")
	
	# Test interactable object registration
	var house_manager = $House
	var interactables = house_manager.interactable_objects
	
	print("Found interactable objects:")
	for type in interactables:
		print("- ", type, ": ", interactables[type].size(), " objects")
	
	# Test navigation
	var nav_node = $House/Navigation
	if nav_node:
		if nav_node.navigation_mesh:
			print("Navigation mesh exists!")
			print("Cell size: ", nav_node.navigation_mesh.cell_size)
			print("Cell height: ", nav_node.navigation_mesh.cell_height)
		else:
			print("ERROR: Navigation mesh not created!")
	
	# Create a test navigation path between two random points
	if nav_node:
		var start_pos = $House/HouseLayout/LivingRoom.global_position
		var end_pos = $House/HouseLayout/Bedroom.global_position
		
		# Create debug visualization of path
		_test_navigation_path(start_pos, end_pos)

func _setup_debug_ui():
	# Create a simple UI for debugging
	var ui = Control.new()
	ui.name = "DebugUI"
	
	var label = Label.new()
	label.name = "StatusLabel"
	label.text = "House Test Running..."
	label.position = Vector2(20, 20)
	
	ui.add_child(label)
	add_child(ui)

func _test_navigation_path(start_pos: Vector3, end_pos: Vector3):
	# Get the navigation instance
	var navigation = $House/Navigation
	
	if navigation:
		# Get a navigation path
		var path = NavigationServer3D.map_get_path(
			NavigationServer3D.get_maps()[0],
			start_pos,
			end_pos,
			true
		)
		
		print("Navigation path found with ", path.size(), " points")
		
		# Visualize the path
		if path.size() > 0:
			var path_visual = ImmediateMesh.new()
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(1, 0, 0)
			material.flags_unshaded = true
			material.flags_no_depth_test = true
			
			var path_instance = MeshInstance3D.new()
			path_instance.name = "DebugPath"
			path_instance.mesh = path_visual
			path_instance.material_override = material
			
			add_child(path_instance)
			
			path_visual.clear_surfaces()
			path_visual.surface_begin(Mesh.PRIMITIVE_LINES)
			
			for i in range(path.size() - 1):
				var start = path[i]
				var end = path[i + 1]
				
				# Draw line segments
				path_visual.surface_add_vertex(start)
				path_visual.surface_add_vertex(end)
			
			path_visual.surface_end()
			
			print("Path visualization created")
		else:
			print("ERROR: No navigation path found between points")
