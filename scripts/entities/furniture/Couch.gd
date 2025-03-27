class_name Couch
extends Furniture

# Couch-specific properties
@export var comfort_level: float = 0.7
@export var seats: int = 3

func _ready():
	super._ready()
	
	# Set couch defaults
	furniture_name = "Couch"
	furniture_type = FurnitureType.SEATING
	interaction_type = InteractionType.SIT
	max_users = seats
	
	# Create a basic shape if no model is loaded
	if get_child_count() == 0:
		var mesh = CSGBox3D.new()
		mesh.size = Vector3(2.0, 0.5, 0.8)
		mesh.position = Vector3(0, 0.25, 0)
		
		var back = CSGBox3D.new()
		back.size = Vector3(2.0, 0.6, 0.2)
		back.position = Vector3(0, 0.55, -0.3)
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.2, 0.4, 0.8)  # Blue couch
		mesh.material = material
		back.material = material
		
		add_child(mesh)
		add_child(back)
		
		# Add interaction area
		var area = Area3D.new()
		area.name = "InteractionArea"
		
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(2.5, 1.5, 1.3)
		collision_shape.shape = box_shape
		collision_shape.position = Vector3(0, 0.75, 0)
		
		area.add_child(collision_shape)
		add_child(area)
		
		# Connect signals
		area.body_entered.connect(_on_interaction_area_body_entered)
		area.body_exited.connect(_on_interaction_area_body_exited)
		
		# Add highlight
		var highlight = CSGBox3D.new()
		highlight.name = "Highlight"
		highlight.size = Vector3(2.1, 0.51, 0.81)
		highlight.position = Vector3(0, 0.25, 0)
		var highlight_material = StandardMaterial3D.new()
		highlight_material.albedo_color = Color(1, 1, 0, 0.3)  # Yellow highlight
		highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		highlight.material = highlight_material
		highlight.visible = false
		add_child(highlight)

func get_satisfaction_value(need_type: String) -> float:
	match need_type:
		"rest":
			return 0.4 * comfort_level
		"social":
			# More satisfaction if multiple users
			return 0.3 * float(current_users.size()) / float(max_users)
	return 0.0
