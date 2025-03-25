extends Node

class_name AnimalStateMachine

# Current active state
var current_state: AnimalState
# Dictionary of all available states
var states: Dictionary = {}

func _ready():
    # Register all child states
    for child in get_children():
        if child is AnimalState:
            states[child.state_name] = child
            child.state_machine = self
    
    # Start with idle state if available, otherwise use the first state
    if states.has("Idle"):
        transition_to("Idle")
    elif states.size() > 0:
        transition_to(states.keys()[0])

func _process(delta):
    # Update current state
    if current_state:
        current_state.update(delta)
        
        # Check for automatic state transitions
        var new_state = current_state.get_transition()
        if new_state != "":
            transition_to(new_state)

func transition_to(state_name: String) -> void:
    # Skip if trying to transition to the same state
    if current_state and current_state.state_name == state_name:
        return
        
    # Exit current state
    if current_state:
        current_state.exit()
    
    # Enter new state
    if states.has(state_name):
        current_state = states[state_name]
        current_state.enter()
    else:
        push_error("State '" + state_name + "' not found in state machine")
