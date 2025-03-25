extends AnimalState

func _init():
    state_name = "Sleep"

func enter() -> void:
    print(animal.animal_name + " is now sleeping")
    # Here we would play the sleeping animation
    
func update(delta: float) -> void:
    # While sleeping, recover energy
    animal.energy = min(100.0, animal.energy + 0.3 * delta)
    
func get_transition() -> String:
    # When energy is restored, return to idle
    if animal.energy > 90.0:
        return "Idle"
    
    return ""
