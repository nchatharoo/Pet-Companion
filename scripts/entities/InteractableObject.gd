class_name InteractableObject
extends Node3D

# Signal emitted when the player interacts with this object
signal interaction_started(entity)
signal interaction_completed(entity)

# Types of interactions this object supports
enum InteractionType {
	NONE,
	SIT,
	SLEEP,
	EAT,
	PLAY,
	USE
}

# Default properties
@export var interaction_type: InteractionType = InteractionType.NONE
@export var interaction_radius: float = 1.5
@export var interaction_point: Vector3 = Vector3.ZERO
@export var interaction_duration: float = 2.0
@export var animal_compatible: bool = true
@export var human_compatible: bool = true

# Current state
var is_in_use: bool = false
var current_user = null

# Visual feedback for interaction availability
@onready var highlight = $Highlight if has_node("Highlight") else null

func _ready():
	# Add to the interactable group for easy finding
	add_to_group("interactable")
	
	# Set up the highlight if it exists
	if highlight:
		highlight.visible = false

func can_interact(entity) -> bool:
	# Check if this object can be interacted with by the given entity
	if is_in_use and current_user != entity:
		return false
		
	if entity.is_in_group("animal") and not animal_compatible:
		return false
		
	if entity.is_in_group("player") and not human_compatible:
		return false
		
	return true

func get_interaction_type() -> String:
	# Convert the enum to a string for the HouseManager
	match interaction_type:
		InteractionType.SIT:
			return "sit"
		InteractionType.SLEEP:
			return "sleep"
		InteractionType.EAT:
			return "eat"
		InteractionType.PLAY:
			return "play"
		InteractionType.USE:
			return "use"
		_:
			return "none"

func get_interaction_position() -> Vector3:
	# Return the position where an entity should move to interact
	return global_position + interaction_point

func start_interaction(entity):
	if not can_interact(entity):
		return false
		
	is_in_use = true
	current_user = entity
	emit_signal("interaction_started", entity)
	
	# Start a timer for the interaction duration
	var timer = get_tree().create_timer(interaction_duration)
	await timer.timeout
	
	complete_interaction()
	return true

func complete_interaction():
	if current_user:
		emit_signal("interaction_completed", current_user)
		
	is_in_use = false
	current_user = null

func highlight_on():
	if highlight:
		highlight.visible = true

func highlight_off():
	if highlight:
		highlight.visible = false

func _on_interaction_area_body_entered(body):
	# When an entity enters the interaction area, show the highlight
	if (body.is_in_group("player") and human_compatible) or \
	   (body.is_in_group("animal") and animal_compatible):
		highlight_on()

func _on_interaction_area_body_exited(body):
	# When an entity leaves the interaction area, hide the highlight
	if (body.is_in_group("player") and human_compatible) or \
	   (body.is_in_group("animal") and animal_compatible):
		highlight_off()
