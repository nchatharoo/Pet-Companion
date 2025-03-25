extends Node

# Signals for game state changes
signal game_state_changed(new_state, old_state)
signal game_paused(is_paused)
signal game_loaded(success, save_data)
signal game_saved(success)

# Game states enum
enum GameState {
	MAIN_MENU,
	CHARACTER_CREATION,
	GAMEPLAY,
	PAUSED,
	SETTINGS,
	LOADING
}

# Current and previous game states
@export var current_state: int = GameState.MAIN_MENU:
	set(value):
		set_current_state(value)
		
var previous_state: int = GameState.MAIN_MENU

# Game status tracking
@export var is_paused: bool = false:
	set(value):
		set_paused(value)
		
@export var current_save_slot: int = 1
@export var debug_mode: bool = false:
	set(value):
		set_debug_mode(value)

# Game version for save compatibility
const GAME_VERSION: String = "0.1.0"

# Dictionary to store current player information
var player_data: Dictionary = {}

# Called when the node enters the scene tree
func _ready() -> void:
	print("GameManager initialized")
	# Make sure GameManager persists during scene changes
	process_mode = Node.PROCESS_MODE_ALWAYS

# State management
# Changes the current game state and handles transitions
func set_current_state(new_state: int) -> void:
	if new_state == current_state:
		return
		
	previous_state = current_state
	current_state = new_state
	
	# Handle state-specific behaviors
	match current_state:
		GameState.MAIN_MENU:
			set_paused(false)
		GameState.PAUSED:
			set_paused(true)
		GameState.GAMEPLAY:
			set_paused(false)
	
	game_state_changed.emit(current_state, previous_state)
	
	if debug_mode:
		print("Game state changed to: ", _state_to_string(current_state))

# Pause management
# Controls game pause state
func set_paused(value: bool) -> void:
	if is_paused == value:
		return
		
	is_paused = value
	get_tree().paused = is_paused
	game_paused.emit(is_paused)
	
	if debug_mode:
		print("Game paused: ", is_paused)

# Toggles the pause state
func toggle_pause() -> void:
	if is_paused:
		set_paused(false)
		# If we were in the PAUSED state, return to previous state
		if current_state == GameState.PAUSED:
			set_current_state(previous_state)
	else:
		set_paused(true)
		# Save current state and go to PAUSED
		set_current_state(GameState.PAUSED)

# Sets the debug mode
func set_debug_mode(value: bool) -> void:
	debug_mode = value
	
	if debug_mode:
		print("Debug mode enabled")
	else:
		print("Debug mode disabled")

# Save system
# Saves the current game state to the specified slot
# Returns true if save was successful
func save_game(slot: int = -1) -> bool:
	if slot > 0:
		current_save_slot = slot
	
	if debug_mode:
		print("Saving game to slot ", current_save_slot)
	
	# Create save data structure
	var save_data = {
		"version": GAME_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"player": player_data,
		# Additional data will be added when other systems are implemented
	}
	
	# This is a placeholder - actual implementation will use the DatabaseManager
	var success = _write_save_data(save_data)
	game_saved.emit(success)
	return success

# Load system
# Loads a game from the specified slot
# Returns true if load was successful
func load_game(slot: int = -1) -> bool:
	if slot > 0:
		current_save_slot = slot
	
	set_current_state(GameState.LOADING)
	
	if debug_mode:
		print("Loading game from slot ", current_save_slot)
	
	# This is a placeholder - actual implementation will use the DatabaseManager
	var save_data = _read_save_data()
	var success = false
	
	if save_data:
		# Version compatibility check
		if save_data.has("version") and _is_compatible_version(save_data.version):
			# Load player data
			if save_data.has("player"):
				player_data = save_data.player
			
			success = true
			
			if debug_mode:
				print("Game loaded successfully")
		else:
			push_error("Incompatible save version")
	else:
		push_error("Failed to load save data")
	
	game_loaded.emit(success, save_data if success else {})
	
	# Return to appropriate state
	if success:
		set_current_state(GameState.GAMEPLAY)
	else:
		set_current_state(GameState.MAIN_MENU)
	
	return success

# Checks if a save exists in the specified slot
func does_save_exist(slot: int = -1) -> bool:
	if slot <= 0:
		slot = current_save_slot
	
	# This is a placeholder - will be implemented with the DatabaseManager
	return false

# Scene transition system
# Changes to a new scene
func change_scene(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		push_error("Scene does not exist: " + scene_path)
		return
	
	# Set loading state
	set_current_state(GameState.LOADING)
	
	# Change to the new scene
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("Failed to change scene to: " + scene_path)
		return
	
	if debug_mode:
		print("Scene changed to: " + scene_path)

# Gets a formatted debug string with current state information
func get_debug_info() -> String:
	var info = "GameManager Debug Info:\n"
	info += "Current State: " + _state_to_string(current_state) + "\n"
	info += "Previous State: " + _state_to_string(previous_state) + "\n"
	info += "Is Paused: " + str(is_paused) + "\n"
	info += "Current Save Slot: " + str(current_save_slot) + "\n"
	info += "Game Version: " + GAME_VERSION + "\n"
	info += "Debug Mode: " + str(debug_mode) + "\n"
	
	return info

# PRIVATE METHODS

# Converts a state enum value to a readable string
func _state_to_string(state: int) -> String:
	match state:
		GameState.MAIN_MENU: return "MAIN_MENU"
		GameState.CHARACTER_CREATION: return "CHARACTER_CREATION"
		GameState.GAMEPLAY: return "GAMEPLAY"
		GameState.PAUSED: return "PAUSED"
		GameState.SETTINGS: return "SETTINGS"
		GameState.LOADING: return "LOADING"
		_: return "UNKNOWN"

# Checks if a save version is compatible with current game version
func _is_compatible_version(version: String) -> bool:
	var current_parts = GAME_VERSION.split(".")
	var save_parts = version.split(".")
	
	# Major version must match
	return current_parts[0] == save_parts[0]

# Placeholder save data writer
# Will be replaced with actual database operations in a later step
func _write_save_data(data: Dictionary) -> bool:
	# This is a placeholder
	return true

# Placeholder save data reader
# Will be replaced with actual database operations in a later step
func _read_save_data() -> Dictionary:
	# This is a placeholder
	return {}
