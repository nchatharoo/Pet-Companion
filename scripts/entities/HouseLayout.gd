class_name HouseLayout
extends Node3D

# Signal emitted when the house is fully loaded and ready
signal house_ready

# References to instanced rooms
var living_room
var kitchen
var bedroom
var bathroom

func _ready():
	# Load room scenes
	_load_rooms()
	
	# Position rooms according to layout
	_position_rooms()
	
	# Set up room connections (doorways)
	_set_up_connections()
	
	# Let the rest of the game know the house is ready
	emit_signal("house_ready")

func _load_rooms():
	# Instance the room scenes
	living_room = load("res://scenes/house/rooms/living_room.tscn").instantiate()
	kitchen = load("res://scenes/house/rooms/kitchen.tscn").instantiate()
	bedroom = load("res://scenes/house/rooms/bedroom.tscn").instantiate()
	bathroom = load("res://scenes/house/rooms/bathroom.tscn").instantiate()
	
	# Add rooms to the scene
	$LivingRoom.add_child(living_room)
	$Kitchen.add_child(kitchen)
	$Bedroom.add_child(bedroom)
	$Bathroom.add_child(bathroom)

func _position_rooms():
	# Position rooms relative to each other
	# Living room is at the center
	$LivingRoom.position = Vector3(0, 0, 0)
	
	# Kitchen is to the right
	var living_room_size = living_room.room_size
	var kitchen_size = kitchen.room_size
	$Kitchen.position = Vector3(
		living_room_size.x/2 + kitchen_size.x/2,
		0,
		0
	)
	
	# Bedroom is behind
	var bedroom_size = bedroom.room_size
	$Bedroom.position = Vector3(
		0,
		0,
		-living_room_size.z/2 - bedroom_size.z/2
	)
	
	# Bathroom is behind kitchen
	var bathroom_size = bathroom.room_size
	$Bathroom.position = Vector3(
		$Kitchen.position.x,
		0,
		-kitchen_size.z/2 - bathroom_size.z/2
	)

func _set_up_connections():
	# Here we would create doorways between rooms
	# For now, we'll just remove the adjoining walls
	# This would be replaced with actual doorway models later
	
	# Connection between living room and kitchen
	var living_room_east_wall = living_room.walls[2]  # East wall
	living_room_east_wall.size.y = living_room_east_wall.size.y * 0.5
	living_room_east_wall.position.y = living_room_east_wall.position.y + living_room_east_wall.size.y/2
	
	var kitchen_west_wall = kitchen.walls[3]  # West wall
	kitchen_west_wall.size.y = kitchen_west_wall.size.y * 0.5
	kitchen_west_wall.position.y = kitchen_west_wall.position.y + kitchen_west_wall.size.y/2
	
	# Connection between living room and bedroom
	var living_room_north_wall = living_room.walls[0]  # North wall
	living_room_north_wall.size.x = living_room_north_wall.size.x * 0.7
	living_room_north_wall.position.x = living_room_north_wall.position.x + living_room_north_wall.size.x * 0.3
	
	var bedroom_south_wall = bedroom.walls[1]  # South wall
	bedroom_south_wall.size.x = bedroom_south_wall.size.x * 0.7
	bedroom_south_wall.position.x = bedroom_south_wall.position.x + bedroom_south_wall.size.x * 0.3
	
	# Connection between kitchen and bathroom
	var kitchen_north_wall = kitchen.walls[0]  # North wall
	kitchen_north_wall.size.x = kitchen_north_wall.size.x * 0.7
	kitchen_north_wall.position.x = kitchen_north_wall.position.x + kitchen_north_wall.size.x * 0.3
	
	var bathroom_south_wall = bathroom.walls[1]  # South wall
	bathroom_south_wall.size.x = bathroom_south_wall.size.x * 0.7
	bathroom_south_wall.position.x = bathroom_south_wall.position.x + bathroom_south_wall.size.x * 0.3

func get_room_by_name(name: String) -> Node3D:
	match name.to_lower():
		"living_room":
			return $LivingRoom
		"kitchen":
			return $Kitchen
		"bedroom":
			return $Bedroom
		"bathroom":
			return $Bathroom
	return null

func get_random_position_in_room(room_name: String) -> Vector3:
	var room_node = get_room_by_name(room_name)
	if room_node and room_node.get_child_count() > 0:
		var room = room_node.get_child(0)
		if room.has_method("get_random_position"):
			return room_node.global_position + room.get_random_position()
	
	# Default return if room not found
	return Vector3.ZERO
