extends AnimalState

func _init():
    state_name = "Idle"

func enter() -> void:
    print(animal.animal_name + " is now idle")
    # Here we would play the idle animation
    
func update(delta: float) -> void:
    # Regular updates while in idle state
    pass
    
func get_transition() -> String:
    # Check conditions for state transitions
    if animal.hunger > 75.0:
        return "Eat"
    elif animal.energy < 30.0:
        return "Sleep"
    
    return ""
