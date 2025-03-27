class_name Bed
extends Furniture

# Bed-specific properties
@export var comfort_level: float = 0.9
@export var is_pet_bed: bool = false

func _ready():
	super._ready()
	
	# Set bed defaults
	furniture_name = "Bed"
	furniture_type = FurnitureType.SLEEPING
	interaction_type = InteractionType.SLEEP
	max_users = 1 if is_pet_bed else 2
	
	# Adjust compatibility based on bed type
	if is_pet_bed:
		furniture_name = "Pet Bed"
		human_compatible = false
	else:
		animal_compatible = false
	
	# Create a basic shape if no model is loaded
	if get_child_count() == 0:
		var mesh = CSGBox3D.new()
		if is_pet_bed:
			mesh.size = Vector3(0.8, 0.2, 0.8)
			mesh.position = Vector3(0, 0.1, 0)
		else:
			mesh.size = Vector3(2.0, 0.4, 1.6)
			mesh.position = Vector3(0, 0.2, 0)
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.8, 0.8, 0.9)  # Light blue/gray bed
		mesh.material = material
		
		add_child(mesh)
		
		# Add interaction area
		var area = Area3D.new()
		area.name = "InteractionArea"
		
		var collision_shape = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		if is_pet_bed:
			box_shape.size = Vector3(1.2, 1.0, 1.2)
			collision_shape.position = Vector3(0, 0.5, 0)
		else:
			box_shape.size = Vector3(2.5, 1.5, 2.1)
			collision_shape.position = Vector3(0, 0.75, 0)
			
		collision_shape.shape = box_shape
		
		area.add_child(collision_shape)
		add_child(area)
		
		# Connect signals
		area.body_entered.connect(_on_interaction_area_body_entered)
		area.body_exited.connect(_on_interaction_area_body_exited)
		
		# Add highlight
		var highlight = CSGBox3D.new()
		highlight.name = "Highlight"
		if is_pet_bed:
			highlight.size = Vector3(0.9, 0.21, 0.9)
			highlight.position = Vector3(0, 0.1, 0)
		else:
			highlight.size = Vector3(2.1, 0.41, 1.7)
			highlight.position = Vector3(0, 0.2, 0)
		
		var highlight_material = StandardMaterial3D.new()
		highlight_material.albedo_color = Color(1, 1, 0, 0.3)  # Yellow highlight
		highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		highlight.material = highlight_material
		highlight.visible = false
		add_child(highlight)

func get_satisfaction_value(need_type: String) -> float:
	match need_type:
		"rest":
			return 0.8 * comfort_level
		"sleep":
			return 1.0 * comfort_level
	return 0.0
