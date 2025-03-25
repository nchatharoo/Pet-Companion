extends CharacterBody3D

class_name Animal

# Animal base properties
@export var animal_name: String = "Unnamed"
@export var animal_type: String = "Unknown"
@export var energy: float = 100.0
@export var hunger: float = 0.0
@export var happiness: float = 100.0
@export var social: float = 100.0
@export var hygiene: float = 100.0

# Need decay rates (per second)
@export var energy_decay: float = 0.05
@export var hunger_growth: float = 0.08
@export var happiness_decay: float = 0.03
@export var social_decay: float = 0.02
@export var hygiene_decay: float = 0.04

# Reference to state machine
var state_machine: Node

func _ready():
    # Initialize state machine
    state_machine = $StateMachine
    
func _process(delta):
    # Update needs
    energy = max(0.0, energy - energy_decay * delta)
    hunger = min(100.0, hunger + hunger_growth * delta)
    happiness = max(0.0, happiness - happiness_decay * delta)
    social = max(0.0, social - social_decay * delta)
    hygiene = max(0.0, hygiene - hygiene_decay * delta)
    
func interact_with(interaction_type: String) -> bool:
    # Base interaction handling
    # To be overridden by specific animal types
    return false
