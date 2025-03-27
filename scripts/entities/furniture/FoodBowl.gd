class_name FoodBowl
extends Furniture

# Food bowl properties
@export var food_type: String = "kibble"
@export var food_amount: float = 1.0  # 0.0 to 1.0
@export var refill_time: float = 10.0  # Seconds between automatic refills

var _refill_timer = null

func _ready():
	super._ready()
	
	# Set food bowl defaults
	furniture_name = "Food Bowl"
	furniture_type = FurnitureType.EATING
	interaction_type = InteractionType.EAT
	max_users = 1
	human_compatible = false
	
	# Create a basic shape if no model is loaded
	if get_child_count() == 0:
		var bowl_mesh = CSGCylinder3D.new()
		bowl_mesh.radius = 0.3
		bowl_mesh.height = 0.1
		bowl_mesh.position = Vector3(0, 0.05, 0)
		
		var food_mesh = CSGCylinder3D.new()
		food_mesh.name = "Food"
		food_mesh.radius = 0.25
		food_mesh.height = 0.05
		food_mesh.position = Vector3(0, 0.075, 0)
		
		var bowl_material = StandardMaterial3D.new()
		bowl_material.albedo_color = Color(0.7, 0.7, 0.7)  # Gray bowl
		bowl_mesh.material = bowl_material
		
		var food_material = StandardMaterial3D.new()
		food_material.albedo_color = Color(0.6, 0.4, 0.2)  # Brown food
		food_mesh.material = food_material
		
		add_child(bowl_mesh)
		add_child(food_mesh)
		
		# Add interaction area
		var area = Area3D.new()
		area.name = "InteractionArea"
		
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = 0.8
		collision_shape.shape = sphere_shape
		collision_shape.position = Vector3(0, 0.4, 0)
		
		area.add_child(collision_shape)
		add_child(area)
		
		# Connect signals
		area.body_entered.connect(_on_interaction_area_body_entered)
		area.body_exited.connect(_on_interaction_area_body_exited)
		
		# Add highlight
		var highlight = CSGCylinder3D.new()
		highlight.name = "Highlight"
		highlight.radius = 0.35
		highlight.height = 0.11
		highlight.position = Vector3(0, 0.05, 0)
		var highlight_material = StandardMaterial3D.new()
		highlight_material.albedo_color = Color(1, 1, 0, 0.3)  # Yellow highlight
		highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		highlight.material = highlight_material
		highlight.visible = false
		add_child(highlight)
	
	# Start refill timer
	_refill_timer = Timer.new()
	_refill_timer.wait_time = refill_time
	_refill_timer.autostart = true
	_refill_timer.timeout.connect(_on_refill_timer_timeout)
	add_child(_refill_timer)
	
	# Update food display
	_update_food_display()

func can_interact(entity) -> bool:
	# Can only interact if there's food
	if food_amount <= 0.0:
		return false
		
	return super.can_interact(entity)

func start_interaction(entity):
	if super.start_interaction(entity):
		# Reduce food amount
		food_amount = max(0.0, food_amount - 0.25)
		_update_food_display()
		return true
	return false

func get_satisfaction_value(need_type: String) -> float:
	if need_type == "hunger":
		return food_amount * 0.8
	return 0.0

func _on_refill_timer_timeout():
	# Automatically refill bowl over time
	if food_amount < 1.0:
		food_amount = min(1.0, food_amount + 0.2)
		_update_food_display()

func _update_food_display():
	# Update the food mesh to reflect amount
	var food_node = get_node_or_null("Food")
	if food_node:
		food_node.height = 0.05 * food_amount
		food_node.position.y = 0.05 + (food_node.height / 2)
		food_node.visible = food_amount > 0.0
