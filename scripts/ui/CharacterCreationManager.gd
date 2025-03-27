extends Control
class_name CharacterCreationManager

# Signals
signal character_created(character: PlayerCharacter)

# References to UI components
@onready var name_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/NameSection/LineEdit
@onready var character_view: SubViewport = $CharacterViewportContainer/CharacterViewport
@onready var character_model_controller: CharacterModelController = $CharacterViewportContainer/CharacterViewport/CharacterModelController

# Color pickers
@onready var skin_color_picker: ColorPickerButton = $PanelContainer/MarginContainer/VBoxContainer/AppearanceSection/SkinColor/ColorPickerButton
@onready var hair_color_picker: ColorPickerButton = $PanelContainer/MarginContainer/VBoxContainer/AppearanceSection/HairColor/ColorPickerButton
@onready var eye_color_picker: ColorPickerButton = $PanelContainer/MarginContainer/VBoxContainer/AppearanceSection/EyeColor/ColorPickerButton

# Hair style selector
@onready var hair_style_prev_button: Button = $PanelContainer/MarginContainer/VBoxContainer/AppearanceSection/HairStyle/PrevButton
@onready var hair_style_next_button: Button = $PanelContainer/MarginContainer/VBoxContainer/AppearanceSection/HairStyle/NextButton
@onready var hair_style_label: Label = $PanelContainer/MarginContainer/VBoxContainer/AppearanceSection/HairStyle/Label

# Gender selection
@onready var gender_option_button: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/AppearanceSection/Gender/OptionButton

# Buttons
@onready var create_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsSection/CreateButton
@onready var cancel_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsSection/CancelButton

# Character data
var character: PlayerCharacter = null
var current_hair_style: int = 0
var max_hair_styles: int = 5 # Matches the number of styles defined in CharacterModelController

# Connected singletons
var game_manager = null

func _ready() -> void:
	# Initialize character
	character = PlayerCharacter.new()
	
	# Get required singletons
	game_manager = get_node("/root/GameManager")
	if not game_manager:
		push_error("GameManager singleton not found")
	
	# Set up initial UI state
	_setup_ui()
	
	# Connect signals
	_connect_signals()
	
	# Update model to initial state
	_update_character_model()

func _setup_ui() -> void:
	# Set up color pickers with initial values
	skin_color_picker.color = character.skin_color
	hair_color_picker.color = character.hair_color
	eye_color_picker.color = character.eye_color
	
	# Set up hair style selector
	current_hair_style = character.hair_style
	_update_hair_style_label()
	
	# Set up gender dropdown
	gender_option_button.clear()
	gender_option_button.add_item("Neutral", 0)
	gender_option_button.add_item("Masculine", 1)
	gender_option_button.add_item("Feminine", 2)
	
	# Select default gender
	match character.gender:
		"neutral":
			gender_option_button.select(0)
		"masculine":
			gender_option_button.select(1)
		"feminine":
			gender_option_button.select(2)
		_:
			gender_option_button.select(0) # Default to neutral

func _connect_signals() -> void:
	# Connect color picker signals
	skin_color_picker.color_changed.connect(_on_skin_color_changed)
	hair_color_picker.color_changed.connect(_on_hair_color_changed)
	eye_color_picker.color_changed.connect(_on_eye_color_changed)
	
	# Connect hair style buttons
	hair_style_prev_button.pressed.connect(_on_prev_hair_style)
	hair_style_next_button.pressed.connect(_on_next_hair_style)
	
	# Connect gender selection
	gender_option_button.item_selected.connect(_on_gender_selected)
	
	# Connect action buttons
	create_button.pressed.connect(_on_create_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

# Update the character model with current settings
func _update_character_model() -> void:
	if character_model_controller:
		character_model_controller.set_skin_color(character.skin_color)
		character_model_controller.set_hair_style(character.hair_style)
		character_model_controller.set_hair_color(character.hair_color)
		character_model_controller.set_eye_color(character.eye_color)
		character_model_controller.set_gender(character.gender)

# Update the hair style label
func _update_hair_style_label() -> void:
	hair_style_label.text = "Style " + str(current_hair_style + 1)

# Signal handlers
func _on_skin_color_changed(color: Color) -> void:
	character.skin_color = color
	_update_character_model()

func _on_hair_color_changed(color: Color) -> void:
	character.hair_color = color
	_update_character_model()

func _on_eye_color_changed(color: Color) -> void:
	character.eye_color = color
	_update_character_model()

func _on_prev_hair_style() -> void:
	current_hair_style = (current_hair_style - 1) if current_hair_style > 0 else max_hair_styles - 1
	character.hair_style = current_hair_style
	_update_hair_style_label()
	_update_character_model()

func _on_next_hair_style() -> void:
	current_hair_style = (current_hair_style + 1) % max_hair_styles
	character.hair_style = current_hair_style
	_update_hair_style_label()
	_update_character_model()

func _on_gender_selected(index: int) -> void:
	match index:
		0:
			character.gender = "neutral"
		1:
			character.gender = "masculine"
		2:
			character.gender = "feminine"
	_update_character_model()

func _on_create_pressed() -> void:
	# Update character name
	character.player_name = name_input.text
	
	if character.player_name.strip_edges().is_empty():
		# Show error for empty name
		var error_dialog = AcceptDialog.new()
		error_dialog.title = "Invalid Name"
		error_dialog.dialog_text = "Please enter a character name"
		add_child(error_dialog)
		error_dialog.popup_centered()
		await error_dialog.confirmed
		error_dialog.queue_free()
		return
	
	# Generate unique ID and update timestamps if not already set
	if character.character_id.is_empty():
		character.character_id = character.generate_unique_id()
		character.creation_date = Time.get_datetime_dict_from_system()
	
	character.last_saved = Time.get_datetime_dict_from_system()
	
	# Emit signal with the created character
	character_created.emit(character)
	
	# Transition to gameplay (could be handled by the parent scene)
	if game_manager:
		game_manager.start_game_with_character(character)

func _on_cancel_pressed() -> void:
	# Return to main menu
	if game_manager:
		game_manager.return_to_main_menu()
