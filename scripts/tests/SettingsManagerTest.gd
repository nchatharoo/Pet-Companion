extends Control

# Node references
@onready var category_tabs = $TabContainer
@onready var settings_container = $TabContainer/Graphics/SettingsContainer
@onready var test_results_label = $TestResultsPanel/TestResultsLabel
@onready var reset_button = $ControlPanel/ResetButton
@onready var save_button = $ControlPanel/SaveButton
@onready var load_button = $ControlPanel/LoadButton
@onready var platform_label = $InfoPanel/PlatformLabel

# Settings UI elements
var settings_ui = {}

func _ready():
	# Setup UI
	_setup_ui()
	
	# Connect to SettingsManager signals
	SettingsManager.settings_changed.connect(_on_settings_changed)
	SettingsManager.settings_loaded.connect(_on_settings_loaded)
	SettingsManager.settings_saved.connect(_on_settings_saved)
	
	# Connect button signals
	reset_button.pressed.connect(_on_reset_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	
	# Display platform info
	_show_platform_info()
	
	# Update UI with current settings
	_update_all_ui()
	
	test_results_label.text = "Test scene ready. SettingsManager singleton is accessible."

# Set up UI elements for each settings category
func _setup_ui():
	# Graphics settings
	_add_setting_slider(SettingsManager.Category.GRAPHICS, "quality_preset", 
		"Quality Preset", 0, 2, 1, "Low", "High")
	_add_setting_checkbox(SettingsManager.Category.GRAPHICS, "shadows_enabled", 
		"Shadows")
	_add_setting_slider(SettingsManager.Category.GRAPHICS, "antialiasing", 
		"Anti-aliasing", 0, 2, 1, "Off", "High")
	_add_setting_checkbox(SettingsManager.Category.GRAPHICS, "vsync", 
		"V-Sync")
	_add_setting_slider(SettingsManager.Category.GRAPHICS, "fps_limit", 
		"FPS Limit", 0, 60, 30, "Unlimited", "60")
	_add_setting_slider(SettingsManager.Category.GRAPHICS, "ui_scale", 
		"UI Scale", 0.5, 1.5, 0.1, "Small", "Large", "%.1f")
	
	# Sound settings
	_add_setting_slider(SettingsManager.Category.SOUND, "master_volume", 
		"Master Volume", 0.0, 1.0, 0.1, "Off", "Max", "%.1f")
	_add_setting_slider(SettingsManager.Category.SOUND, "music_volume", 
		"Music Volume", 0.0, 1.0, 0.1, "Off", "Max", "%.1f")
	_add_setting_slider(SettingsManager.Category.SOUND, "sfx_volume", 
		"SFX Volume", 0.0, 1.0, 0.1, "Off", "Max", "%.1f")
	_add_setting_checkbox(SettingsManager.Category.SOUND, "ui_sounds", 
		"UI Sounds")
	_add_setting_checkbox(SettingsManager.Category.SOUND, "animal_sounds", 
		"Animal Sounds")
	
	# Controls settings
	_add_setting_slider(SettingsManager.Category.CONTROLS, "touch_sensitivity", 
		"Touch Sensitivity", 0.1, 1.0, 0.1, "Low", "High", "%.1f")
	_add_setting_checkbox(SettingsManager.Category.CONTROLS, "invert_camera_y", 
		"Invert Y-Axis")
	_add_setting_slider(SettingsManager.Category.CONTROLS, "camera_speed", 
		"Camera Speed", 0.1, 1.0, 0.1, "Slow", "Fast", "%.1f")
	_add_setting_checkbox(SettingsManager.Category.CONTROLS, "vibration_enabled", 
		"Vibration")
	_add_setting_checkbox(SettingsManager.Category.CONTROLS, "double_tap_enabled", 
		"Double-tap Interaction")
	
	# Gameplay settings
	_add_setting_checkbox(SettingsManager.Category.GAMEPLAY, "tutorial_enabled", 
		"Tutorial")
	_add_setting_checkbox(SettingsManager.Category.GAMEPLAY, "auto_save", 
		"Auto-save")
	_add_setting_slider(SettingsManager.Category.GAMEPLAY, "auto_save_interval", 
		"Auto-save Interval (minutes)", 1, 10, 1, "1 min", "10 min", "%d")
	_add_setting_slider(SettingsManager.Category.GAMEPLAY, "difficulty", 
		"Difficulty", 0, 2, 1, "Easy", "Hard")
	
	# Add language dropdown
	var language_option = OptionButton.new()
	language_option.add_item("English", 0)
	language_option.add_item("French", 1)
	language_option.add_item("Spanish", 2)
	language_option.add_item("German", 3)
	language_option.add_item("Japanese", 4)
	language_option.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	var language_container = HBoxContainer.new()
	var language_label = Label.new()
	language_label.text = "Language:"
	language_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	language_container.add_child(language_label)
	language_container.add_child(language_option)
	category_tabs.get_node("Gameplay/SettingsContainer").add_child(language_container)
	
	# Connect language option
	language_option.item_selected.connect(func(index): 
		var langs = ["en", "fr", "es", "de", "jp"]
		SettingsManager.set_setting(SettingsManager.Category.GAMEPLAY, "language", langs[index])
	)
	
	# Store reference
	settings_ui[str(SettingsManager.Category.GAMEPLAY) + "_language"] = language_option

# Shows platform information detected by SettingsManager
func _show_platform_info():
	var info = "Platform: "
	
	if SettingsManager.is_mobile():
		info += "Mobile ("
		if SettingsManager.is_ios():
			info += "iOS"
		elif SettingsManager.is_android():
			info += "Android"
		info += ")"
	elif SettingsManager.is_desktop():
		info += "Desktop"
	else:
		info += "Unknown"
	
	platform_label.text = info

# Update all UI elements with current settings values
func _update_all_ui():
	for key in settings_ui.keys():
		var parts = key.split("_", true, 1)
		if parts.size() == 2:
			var category = int(parts[0])
			var setting_name = parts[1]
			_update_ui_element(category, setting_name)

# Update a specific UI element with its current setting value
func _update_ui_element(category: int, setting_name: String):
	var ui_key = str(category) + "_" + setting_name
	
	if not settings_ui.has(ui_key):
		return
	
	var ui_element = settings_ui[ui_key]
	var value = SettingsManager.get_setting(category, setting_name)
	
	if ui_element is Slider:
		ui_element.value = value
	elif ui_element is CheckBox:
		ui_element.button_pressed = value
	elif ui_element is OptionButton and setting_name == "language":
		var langs = ["en", "fr", "es", "de", "jp"]
		for i in range(langs.size()):
			if langs[i] == value:
				ui_element.selected = i
				break

# Add a slider for a setting
func _add_setting_slider(category: int, setting_name: String, label_text: String, 
	min_value: float, max_value: float, step: float, 
	min_text: String = "", max_text: String = "", format: String = "%s"):
	
	var container = HBoxContainer.new()
	container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	var label = Label.new()
	label.text = label_text + ":"
	label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	var slider = HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	slider.size_flags_stretch_ratio = 2.0
	
	var value_label = Label.new()
	value_label.set_custom_minimum_size(Vector2(50, 0))
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	container.add_child(label)
	container.add_child(slider)
	container.add_child(value_label)
	
	# Add min/max labels if provided
	if min_text != "" or max_text != "":
		var range_container = HBoxContainer.new()
		range_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		var min_label = Label.new()
		min_label.text = min_text
		min_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		min_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		var max_label = Label.new()
		max_label.text = max_text
		max_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		max_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		range_container.add_child(min_label)
		range_container.add_child(max_label)
		
		var vbox = VBoxContainer.new()
		vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		vbox.add_child(container)
		vbox.add_child(range_container)
		
		category_tabs.get_node(str(SettingsManager._category_to_string(category)).capitalize() + "/SettingsContainer").add_child(vbox)
	else:
		category_tabs.get_node(str(SettingsManager._category_to_string(category)).capitalize() + "/SettingsContainer").add_child(container)
	
	# Set initial value and update value label
	var current_value = SettingsManager.get_setting(category, setting_name)
	slider.value = current_value
	value_label.text = format % current_value
	
	# Connect value change signal
	slider.value_changed.connect(func(value): 
		SettingsManager.set_setting(category, setting_name, value)
		value_label.text = format % value
	)
	
	# Store reference to UI element
	settings_ui[str(category) + "_" + setting_name] = slider

# Add a checkbox for a setting
func _add_setting_checkbox(category: int, setting_name: String, label_text: String):
	var container = HBoxContainer.new()
	container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	var label = Label.new()
	label.text = label_text + ":"
	label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	var checkbox = CheckBox.new()
	checkbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	checkbox.size_flags_stretch_ratio = 2.0
	
	container.add_child(label)
	container.add_child(checkbox)
	
	category_tabs.get_node(str(SettingsManager._category_to_string(category)).capitalize() + "/SettingsContainer").add_child(container)
	
	# Set initial value
	checkbox.button_pressed = SettingsManager.get_setting(category, setting_name)
	
	# Connect toggled signal
	checkbox.toggled.connect(func(button_pressed): 
		SettingsManager.set_setting(category, setting_name, button_pressed)
	)
	
	# Store reference to UI element
	settings_ui[str(category) + "_" + setting_name] = checkbox

# SIGNAL HANDLERS

# Handler for settings changed
func _on_settings_changed(category: int, setting_name: String):
	if setting_name == "":
		# All settings in category changed
		for key in settings_ui.keys():
			var parts = key.split("_", true, 1)
			if parts.size() == 2 and int(parts[0]) == category:
				_update_ui_element(category, parts[1])
	else:
		# Single setting changed
		_update_ui_element(category, setting_name)
	
	test_results_label.text = "Settings changed: Category " + str(category) + ", Setting '" + setting_name + "'"

# Handler for settings loaded
func _on_settings_loaded():
	_update_all_ui()
	test_results_label.text = "Settings loaded successfully"

# Handler for settings saved
func _on_settings_saved():
	test_results_label.text = "Settings saved successfully"

# BUTTON HANDLERS

# Reset all settings to defaults
func _on_reset_pressed():
	SettingsManager.reset_to_defaults()
	test_results_label.text = "Settings reset to defaults"

# Save settings to file
func _on_save_pressed():
	var success = SettingsManager.save_settings()
	if not success:
		test_results_label.text = "Failed to save settings"

# Load settings from file
func _on_load_pressed():
	var success = SettingsManager.load_settings()
	if not success:
		test_results_label.text = "Failed to load settings"

# Test current settings values
func _on_test_settings_pressed():
	SettingsManager.print_all_settings()
	test_results_label.text = "Current settings printed to console"
