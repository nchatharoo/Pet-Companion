class_name Furniture
extends InteractableObject

# Furniture type enumeration
enum FurnitureType {
	SEATING,
	STORAGE,
	SLEEPING,
	EATING,
	PLAYING,
	UTILITY
}

# Furniture attributes
@export var furniture_type: FurnitureType = FurnitureType.SEATING
@export var furniture_name: String = "Generic Furniture"
@export var max_users: int = 1
@export var model_path: String = ""

# Current users
var current_users = []

func _ready():
	super._ready()
	add_to_group("furniture")
	
	# Load the model if specified
	if model_path != "":
		var model = load(model_path)
		if model:
			var model_instance = model.instantiate()
			add_child(model_instance)
		else:
			push_error("Failed to load furniture model: " + model_path)

func can_interact(entity) -> bool:
	# Check if furniture is full
	if current_users.size() >= max_users and not entity in current_users:
		return false
		
	return super.can_interact(entity)

func start_interaction(entity):
	# Add the entity to current users
	if not entity in current_users:
		current_users.append(entity)
		
	return super.start_interaction(entity)

func complete_interaction():
	# Remove the entity from current users
	if current_user in current_users:
		current_users.erase(current_user)
		
	super.complete_interaction()

func get_satisfaction_value(need_type: String) -> float:
	# Return how much this furniture satisfies a specific need
	# This will be overridden by specific furniture classes
	return 0.0
