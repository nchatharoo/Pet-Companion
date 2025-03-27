extends Control

@onready var label = $Label

func _ready():
	if GameManager:
		label.text = "GameManager singleton is accessible.\nCurrent State: " + GameManager._state_to_string(GameManager.current_state)
		print("GameManager Test: Singleton is accessible")
	else:
		label.text = "Error: GameManager singleton is not accessible"
		print("GameManager Test: Error - Singleton is not accessible")
