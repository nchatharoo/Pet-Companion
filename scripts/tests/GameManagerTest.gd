extends Control

# GameManagerTest.gd
# Test script for verifying GameManager singleton functionality

# Node references
@onready var info_label: Label = $InfoLabel
@onready var state_option: OptionButton = $StateOption
@onready var pause_button: Button = $PauseButton
@onready var debug_button: Button = $DebugButton
@onready var save_button: Button = $SaveButton
@onready var load_button: Button = $LoadButton
@onready var test_results_label: Label = $TestResultsLabel

# State option mapping
var state_options = {
	"Main Menu": GameManager.GameState.MAIN_MENU,
	"Character Creation": GameManager.GameState.CHARACTER_CREATION,
	"Gameplay": GameManager.GameState.GAMEPLAY,
	"Paused": GameManager.GameState.PAUSED,
	"Settings": GameManager.GameState.SETTINGS,
	"Loading": GameManager.GameState.LOADING
}

# Called when the node enters the scene tree
func _ready() -> void:
	# Connect to GameManager signals
	GameManager.game_state_changed.connect(_on_game_state_changed)
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_saved.connect(_on_game_saved)
	GameManager.game_loaded.connect(_on_game_loaded)
	
	# Set up UI elements
	_setup_ui()
	
	# Update initial info display
	_update_info()
	
	print("GameManager test scene ready")
	test_results_label.text = "Test Results: GameManager singleton is accessible"

# Sets up UI elements and connections
func _setup_ui() -> void:
	# Populate state dropdown
	state_option.clear()
	for key in state_options.keys():
		state_option.add_item(key)
	
	# Set initial selection to match current state
	for i in range(state_option.get_item_count()):
		var state_name = state_option.get_item_text(i)
		if state_options[state_name] == GameManager.current_state:
			state_option.select(i)
			break
	
	# Connect UI signals
	state_option.item_selected.connect(_on_state_selected)
	pause_button.pressed.connect(_on_pause_pressed)
	debug_button.pressed.connect(_on_debug_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	
	# Set initial button text
	pause_button.text = "Unpause" if GameManager.is_paused else "Pause"
	debug_button.text = "Disable Debug" if GameManager.debug_mode else "Enable Debug"

# Updates the info display with current GameManager state
func _update_info() -> void:
	info_label.text = GameManager.get_debug_info()

# SIGNAL HANDLERS

# Called when the game state changes
func _on_game_state_changed(new_state: int, old_state: int) -> void:
	_update_info()
	
	# Update dropdown selection
	for i in range(state_option.get_item_count()):
		var state_name = state_option.get_item_text(i)
		if state_options[state_name] == GameManager.current_state:
			state_option.select(i)
			break
	
	test_results_label.text = "Test Results: State changed from " + GameManager._state_to_string(old_state) + " to " + GameManager._state_to_string(new_state)

# Called when the game pause state changes
func _on_game_paused(is_paused: bool) -> void:
	_update_info()
	pause_button.text = "Unpause" if is_paused else "Pause"
	test_results_label.text = "Test Results: Game " + ("paused" if is_paused else "unpaused")

# Called when the game is saved
func _on_game_saved(success: bool) -> void:
	if success:
		print("Game saved successfully")
		test_results_label.text = "Test Results: Game saved successfully"
	else:
		print("Game save failed")
		test_results_label.text = "Test Results: Game save failed"
	_update_info()

# Called when the game is loaded
func _on_game_loaded(success: bool, _save_data: Dictionary) -> void:
	if success:
		print("Game loaded successfully")
		test_results_label.text = "Test Results: Game loaded successfully"
	else:
		print("Game load failed")
		test_results_label.text = "Test Results: Game load failed"
	_update_info()

# UI EVENT HANDLERS

# Called when a new state is selected from the dropdown
func _on_state_selected(index: int) -> void:
	var state_name = state_option.get_item_text(index)
	GameManager.set_current_state(state_options[state_name])

# Called when the pause button is pressed
func _on_pause_pressed() -> void:
	GameManager.toggle_pause()

# Called when the debug button is pressed
func _on_debug_pressed() -> void:
	GameManager.set_debug_mode(!GameManager.debug_mode)
	debug_button.text = "Disable Debug" if GameManager.debug_mode else "Enable Debug"
	_update_info()

# Called when the save button is pressed
func _on_save_pressed() -> void:
	GameManager.save_game()

# Called when the load button is pressed
func _on_load_pressed() -> void:
	GameManager.load_game()
