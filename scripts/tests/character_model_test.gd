extends Node3D

# Nodes
@onready var model_display: SubViewport = $ModelViewportContainer/ModelViewport
@onready var model_controller: CharacterModelController = $ModelViewportContainer/ModelViewport/CharacterModelController

# UI controls
@onready var skin_color_picker: ColorPickerButton = $ControlPanel/Controls/SkinColorContainer/SkinColorPicker
@onready var hair_style_left_button: Button = $ControlPanel/Controls/HairStyleContainer/LeftButton
@onready var hair_style_right_button: Button = $ControlPanel/Controls/HairStyleContainer/RightButton
@onready var hair_style_label: Label = $ControlPanel/Controls/HairStyleContainer/StyleLabel
@onready var hair_color_picker: ColorPickerButton = $ControlPanel/Controls/HairColorContainer/HairColorPicker
@onready var eye_color_picker: ColorPickerButton = $ControlPanel/Controls/EyeColorContainer/EyeColorPicker
@onready var status_label: Label = $ControlPanel/Controls/StatusLabel

# Current settings
var current_hair_style: int = 0
var max_hair_styles: int = 5

# Called when the node enters the scene tree for the first time
func _ready():
    # Connect UI signals
    skin_color_picker.color_changed.connect(_on_skin_color_changed)
    hair_style_left_button.pressed.connect(_on_hair_style_left_pressed)
    hair_style_right_button.pressed.connect(_on_hair_style_right_pressed)
    hair_color_picker.color_changed.connect(_on_hair_color_changed)
    eye_color_picker.color_changed.connect(_on_eye_color_changed)
    
    # Connect model controller signals
    model_controller.model_ready.connect(_on_model_ready)
    
    # Initialize UI
    _update_hair_style_display()
    
    # Set initial status
    status_label.text = "Loading model..."

# Signal handlers
func _on_model_ready():
    status_label.text = "Model loaded successfully!"
    
    # Apply initial colors from UI
    model_controller.set_skin_color(skin_color_picker.color)
    model_controller.set_hair_style(current_hair_style)
    model_controller.set_hair_color(hair_color_picker.color)
    model_controller.set_eye_color(eye_color_picker.color)

func _on_skin_color_changed(color: Color):
    model_controller.set_skin_color(color)
    status_label.text = "Skin color updated"

func _on_hair_style_left_pressed():
    current_hair_style = (current_hair_style - 1 + max_hair_styles) % max_hair_styles
    _update_hair_style_display()
    model_controller.set_hair_style(current_hair_style)
    status_label.text = "Hair style updated"

func _on_hair_style_right_pressed():
    current_hair_style = (current_hair_style + 1) % max_hair_styles
    _update_hair_style_display()
    model_controller.set_hair_style(current_hair_style)
    status_label.text = "Hair style updated"

func _on_hair_color_changed(color: Color):
    model_controller.set_hair_color(color)
    status_label.text = "Hair color updated"

func _on_eye_color_changed(color: Color):
    model_controller.set_eye_color(color)
    status_label.text = "Eye color updated"

# Helper methods
func _update_hair_style_display():
    hair_style_label.text = "Style " + str(current_hair_style + 1) + "/" + str(max_hair_styles)
