extends Node

# Signals
signal settings_changed(category, setting_name)
signal settings_loaded
signal settings_saved

# Setting categories
enum Category {
	SOUND,
	GRAPHICS,
	CONTROLS,
	GAMEPLAY
}

# File paths
const SETTINGS_FILE = "user://settings.cfg"

# Default settings
var _default_settings = {
	Category.SOUND: {
		"master_volume": 0.8,  # 0.0 to 1.0
		"music_volume": 0.6,   # 0.0 to 1.0
		"sfx_volume": 0.7,     # 0.0 to 1.0
		"ui_sounds": true,     # Enable/disable UI sounds
		"animal_sounds": true  # Enable/disable animal sounds
	},
	Category.GRAPHICS: {
		"quality_preset": 1,    # 0: Low, 1: Medium, 2: High
		"shadows_enabled": true,
		"antialiasing": 1,      # 0: Off, 1: MSAA 2x, 2: MSAA 4x
		"vsync": true,
		"fps_limit": 60,        # 0: Unlimited, 30, 60, etc.
		"ui_scale": 1.0         # UI scaling factor
	},
	Category.CONTROLS: {
		"touch_sensitivity": 0.8,   # 0.1 to 1.0
		"invert_camera_y": false,
		"camera_speed": 0.5,        # 0.1 to 1.0
		"vibration_enabled": true,  # Haptic feedback
		"double_tap_enabled": true  # Double tap to interact
	},
	Category.GAMEPLAY: {
		"tutorial_enabled": true,
		"auto_save": true,
		"auto_save_interval": 5,     # In minutes
		"difficulty": 1,             # 0: Easy, 1: Normal, 2: Hard
		"language": "en"             # Language code
	}
}

# Current settings
var _settings = {}

# Platform information
var _is_mobile: bool = false
var _is_ios: bool = false
var _is_android: bool = false
var _is_desktop: bool = false

# Called when the node enters the scene tree for first time
func _ready() -> void:
	_detect_platform()
	_initialize_settings()
	print("SettingsManager initialized")

# Platform detection for automatic settings
func _detect_platform() -> void:
	_is_mobile = OS.has_feature("mobile")
	_is_ios = OS.has_feature("iOS")
	_is_android = OS.has_feature("Android")
	_is_desktop = OS.has_feature("pc")
	
	print("Platform detected: " + 
		("Mobile (" + ("iOS" if _is_ios else "Android") + ")" if _is_mobile else "Desktop"))

# Initialize settings with defaults and load saved settings
func _initialize_settings() -> void:
	# Start with default settings
	_settings = _default_settings.duplicate(true)
	
	# Apply platform-specific defaults
	if _is_mobile:
		_settings[Category.GRAPHICS]["quality_preset"] = 0 # Low preset for mobile
		_settings[Category.GRAPHICS]["shadows_enabled"] = false
		_settings[Category.GRAPHICS]["antialiasing"] = 0
		_settings[Category.GRAPHICS]["fps_limit"] = 30
		
	# Load saved settings if they exist
	load_settings()
	
	# Apply the loaded settings
	apply_all_settings()

# GETTERS AND SETTERS

# Get a specific setting value
func get_setting(category: int, setting_name: String, default_value = null):
	if not _settings.has(category) or not _settings[category].has(setting_name):
		return default_value
		
	return _settings[category][setting_name]

# Get all settings in a category
func get_category_settings(category: int) -> Dictionary:
	if not _settings.has(category):
		return {}
		
	return _settings[category].duplicate()

# Set a specific setting value
func set_setting(category: int, setting_name: String, value, apply: bool = true) -> void:
	if not _settings.has(category):
		_settings[category] = {}
		
	_settings[category][setting_name] = value
	settings_changed.emit(category, setting_name)
	
	if apply:
		apply_setting(category, setting_name)

# SETTINGS APPLICATION

# Apply all settings
func apply_all_settings() -> void:
	# Apply each category
	for category in _settings.keys():
		for setting_name in _settings[category].keys():
			apply_setting(category, setting_name)

# Apply a specific setting
func apply_setting(category: int, setting_name: String) -> void:
	if not _settings.has(category) or not _settings[category].has(setting_name):
		return
		
	var value = _settings[category][setting_name]
	
	# Apply different settings based on category
	match category:
		Category.SOUND:
			_apply_sound_setting(setting_name, value)
		Category.GRAPHICS:
			_apply_graphics_setting(setting_name, value)
		Category.CONTROLS:
			_apply_controls_setting(setting_name, value)
		Category.GAMEPLAY:
			_apply_gameplay_setting(setting_name, value)

# Apply sound settings
func _apply_sound_setting(setting_name: String, value) -> void:
	match setting_name:
		"master_volume":
			# Set master bus volume
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 
				linear_to_db(value))
		"music_volume":
			# Set music bus volume if it exists
			var bus_idx = AudioServer.get_bus_index("Music")
			if bus_idx >= 0:
				AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
		"sfx_volume":
			# Set SFX bus volume if it exists
			var bus_idx = AudioServer.get_bus_index("SFX")
			if bus_idx >= 0:
				AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
		"ui_sounds", "animal_sounds":
			# These are just flags that other systems will check
			pass

# Apply graphics settings
func _apply_graphics_setting(setting_name: String, value) -> void:
	match setting_name:
		"quality_preset":
			_apply_quality_preset(value)
		"shadows_enabled":
			# Set shadow quality through project settings
			# In Godot 4, we use ProjectSettings instead of direct RenderingServer manipulation
			if value:
				# Enable shadows with appropriate quality
				ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 2)
				ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 2048 if _is_desktop else 1024)
			else:
				# Disable shadows or set to lowest quality
				ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 0)
				ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 1024)
		"antialiasing":
			# Set antialiasing level
			var msaa_mode = Viewport.MSAA_DISABLED
			if value == 1:
				msaa_mode = Viewport.MSAA_2X
			elif value >= 2:
				msaa_mode = Viewport.MSAA_4X
			
			# Apply to all viewports
			get_viewport().msaa_2d = msaa_mode
			get_viewport().msaa_3d = msaa_mode
		"vsync":
			# Set vertical sync mode
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)
		"fps_limit":
			# Set FPS limit
			if value > 0:
				Engine.max_fps = value
			else:
				Engine.max_fps = 0  # Unlimited
		"ui_scale":
			# UI scaling would be handled by the UI manager
			pass

# Apply controls settings
func _apply_controls_setting(_setting_name: String, _value) -> void:
	# Control settings are mainly referenced by other systems
	# This could be expanded if needed
	pass

# Apply gameplay settings
func _apply_gameplay_setting(_setting_name: String, _value) -> void:
	# Gameplay settings are mainly referenced by other systems
	# This could be expanded if needed
	pass

# Apply quality preset (affects multiple graphics settings)
func _apply_quality_preset(preset: int) -> void:
	match preset:
		0:  # Low
			set_setting(Category.GRAPHICS, "shadows_enabled", false, false)
			set_setting(Category.GRAPHICS, "antialiasing", 0, false)
			set_setting(Category.GRAPHICS, "vsync", _is_desktop, false)
		1:  # Medium
			set_setting(Category.GRAPHICS, "shadows_enabled", true, false)
			set_setting(Category.GRAPHICS, "antialiasing", 1, false)
			set_setting(Category.GRAPHICS, "vsync", true, false)
		2:  # High
			set_setting(Category.GRAPHICS, "shadows_enabled", true, false)
			set_setting(Category.GRAPHICS, "antialiasing", 2, false)
			set_setting(Category.GRAPHICS, "vsync", true, false)
	
	# Apply all the changed settings
	apply_setting(Category.GRAPHICS, "shadows_enabled")
	apply_setting(Category.GRAPHICS, "antialiasing")
	apply_setting(Category.GRAPHICS, "vsync")

# SAVE/LOAD FUNCTIONS

# Save settings to file
func save_settings() -> bool:
	var config = ConfigFile.new()
	
	# Add each category to the config file
	for category in _settings.keys():
		var section = _category_to_string(category)
		for key in _settings[category].keys():
			config.set_value(section, key, _settings[category][key])
	
	# Save the config file
	var error = config.save(SETTINGS_FILE)
	if error != OK:
		push_error("Failed to save settings: " + str(error))
		return false
	
	settings_saved.emit()
	return true

# Load settings from file
func load_settings() -> bool:
	var config = ConfigFile.new()
	
	# Check if the config file exists
	if not FileAccess.file_exists(SETTINGS_FILE):
		print("No settings file found, using defaults")
		return false
	
	# Load the config file
	var error = config.load(SETTINGS_FILE)
	if error != OK:
		push_error("Failed to load settings: " + str(error))
		return false
	
	# Read settings from file
	for category in _settings.keys():
		var section = _category_to_string(category)
		for key in _settings[category].keys():
			if config.has_section_key(section, key):
				_settings[category][key] = config.get_value(section, key)
	
	settings_loaded.emit()
	return true

# Reset all settings to default
func reset_to_defaults() -> void:
	_settings = _default_settings.duplicate(true)
	
	# Apply platform-specific defaults
	if _is_mobile:
		_settings[Category.GRAPHICS]["quality_preset"] = 0
		_settings[Category.GRAPHICS]["shadows_enabled"] = false
		_settings[Category.GRAPHICS]["antialiasing"] = 0
		_settings[Category.GRAPHICS]["fps_limit"] = 30
	
	apply_all_settings()
	settings_changed.emit(-1, "")  # -1 means all categories have changed

# Reset a specific category to default
func reset_category(category: int) -> void:
	if not _default_settings.has(category):
		return
		
	_settings[category] = _default_settings[category].duplicate(true)
	
	# Apply platform-specific defaults for graphics
	if category == Category.GRAPHICS and _is_mobile:
		_settings[Category.GRAPHICS]["quality_preset"] = 0
		_settings[Category.GRAPHICS]["shadows_enabled"] = false
		_settings[Category.GRAPHICS]["antialiasing"] = 0
		_settings[Category.GRAPHICS]["fps_limit"] = 30
	
	# Apply all settings in this category
	for setting_name in _settings[category].keys():
		apply_setting(category, setting_name)
	
	settings_changed.emit(category, "")  # Empty string means all settings in category have changed

# UTILITY FUNCTIONS

# Convert category enum to string for storage
func _category_to_string(category: int) -> String:
	match category:
		Category.SOUND: return "sound"
		Category.GRAPHICS: return "graphics"
		Category.CONTROLS: return "controls"
		Category.GAMEPLAY: return "gameplay"
		_: return "unknown"

# Get platform information
func is_mobile() -> bool:
	return _is_mobile

func is_ios() -> bool:
	return _is_ios

func is_android() -> bool:
	return _is_android

func is_desktop() -> bool:
	return _is_desktop

# Debug function to print all current settings
func print_all_settings() -> void:
	print("===== CURRENT SETTINGS =====")
	for category in _settings.keys():
		print(_category_to_string(category).to_upper() + ":")
		for key in _settings[category].keys():
			print("  " + key + ": " + str(_settings[category][key]))
	print("===========================")
