class_name Room
extends Node3D

# Room properties
@export var room_name: String = "Room"
@export var room_size: Vector3 = Vector3(5, 3, 5)  # width, height, depth
@export var wall_thickness: float = 0.1
@export var floor_height: float = 0.1

# References to room components
var walls = []
var floor_node
var ceiling_node
var furniture = []

func _ready():
	# Add to room group
	add_to_group("room")
	
	# Setup room components
	_setup_room()
	
	# Register furniture
	_register_furniture()

func _setup_room():
	# Create floor if it doesn't exist
	if !has_node("Floor"):
		floor_node = _create_floor()
		add_child(floor_node)
	else:
		floor_node = get_node("Floor")
	
	# Create walls if they don't exist
	if !has_node("Walls"):
		var walls_container = Node3D.new()
		walls_container.name = "Walls"
		add_child(walls_container)
		
		# Create four walls
		var north_wall = _create_wall(Vector3(0, room_size.y/2, -room_size.z/2), Vector3(room_size.x, room_size.y, wall_thickness))
		north_wall.name = "NorthWall"
		walls_container.add_child(north_wall)
		walls.append(north_wall)
		
		var south_wall = _create_wall(Vector3(0, room_size.y/2, room_size.z/2), Vector3(room_size.x, room_size.y, wall_thickness))
		south_wall.name = "SouthWall"
		walls_container.add_child(south_wall)
		walls.append(south_wall)
		
		var east_wall = _create_wall(Vector3(room_size.x/2, room_size.y/2, 0), Vector3(wall_thickness, room_size.y, room_size.z))
		east_wall.name = "EastWall"
		walls_container.add_child(east_wall)
		walls.append(east_wall)
		
		var west_wall = _create_wall(Vector3(-room_size.x/2, room_size.y/2, 0), Vector3(wall_thickness, room_size.y, room_size.z))
		west_wall.name = "WestWall"
		walls_container.add_child(west_wall)
		walls.append(west_wall)
	else:
		var walls_container = get_node("Walls")
		walls.append(walls_container.get_node("NorthWall"))
		walls.append(walls_container.get_node("SouthWall"))
		walls.append(walls_container.get_node("EastWall"))
		walls.append(walls_container.get_node("WestWall"))
	
	# Create ceiling if it doesn't exist
	if !has_node("Ceiling"):
		ceiling_node = _create_ceiling()
		add_child(ceiling_node)
	else:
		ceiling_node = get_node("Ceiling")

func _create_floor():
	var floor_mesh = CSGBox3D.new()
	floor_mesh.name = "Floor"
	floor_mesh.size = Vector3(room_size.x, floor_height, room_size.z)
	floor_mesh.position = Vector3(0, -floor_height/2, 0)
	
	# Set floor material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.8, 0.8)
	floor_mesh.material = material
	
	return floor_mesh

func _create_wall(position, size):
	var wall_mesh = CSGBox3D.new()
	wall_mesh.size = size
	wall_mesh.position = position
	
	# Set wall material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.9, 0.9)
	wall_mesh.material = material
	
	return wall_mesh

func _create_ceiling():
	var ceiling_mesh = CSGBox3D.new()
	ceiling_mesh.name = "Ceiling"
	ceiling_mesh.size = Vector3(room_size.x, floor_height, room_size.z)
	ceiling_mesh.position = Vector3(0, room_size.y + floor_height/2, 0)
	
	# Set ceiling material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.85, 0.85, 0.85)
	ceiling_mesh.material = material
	
	return ceiling_mesh

func _register_furniture():
	# Find all furniture nodes in this room
	for child in get_children():
		if child.is_in_group("furniture"):
			furniture.append(child)

func add_furniture(furniture_node):
	# Add a piece of furniture to this room
	add_child(furniture_node)
	if furniture_node.is_in_group("furniture"):
		furniture.append(furniture_node)

func get_random_position() -> Vector3:
	# Return a random position within this room
	var x_range = room_size.x * 0.8  # Stay away from walls
	var z_range = room_size.z * 0.8
	
	var x = randf_range(-x_range/2, x_range/2)
	var z = randf_range(-z_range/2, z_range/2)
	
	return Vector3(x, 0, z)
