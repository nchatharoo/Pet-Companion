extends Node

class_name AnimalState

# State properties
@export var state_name: String = "BaseState"
# Reference to parent state machine
var state_machine: AnimalStateMachine

# Reference to the animal
var animal: Animal

func _ready():
    # Get reference to animal
    animal = get_parent().get_parent()

# Called when entering this state
func enter() -> void:
    pass

# Called every frame while in this state
func update(delta: float) -> void:
    pass

# Called when exiting this state
func exit() -> void:
    pass

# Determines if state should transition to another state
func get_transition() -> String:
    return ""
