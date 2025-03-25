extends AnimalState

func _init():
    state_name = "Eat"

func enter() -> void:
    print(animal.animal_name + " is now eating")
    # Here we would play the eating animation
    
func update(delta: float) -> void:
    # While eating, reduce hunger
    animal.hunger = max(0.0, animal.hunger - 0.5 * delta)
    
func get_transition() -> String:
    # When hunger is satisfied, return to idle
    if animal.hunger < 20.0:
        return "Idle"
    
    return ""
