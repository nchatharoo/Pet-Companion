extends Node
class_name TestCharacterModel

# Test configuration
var test_mode: String = "visual" # "visual" or "automated"

# Test variables
var resource_manager: Node
var character_data: PlayerCharacter
var model_controller: CharacterModelController

# UI elements for visual testing
var ui_elements = {}

# Initialize the test
func _ready():
    print("Starting Character Model Test")
    
    # Get required systems
    resource_manager = Engine.get_singleton("ResourceManager")
    if not resource_manager:
        printerr("Error: ResourceManager singleton not found")
        return
    
    # Create test character data
    character_data = create_test_character()
    
    # Run appropriate test mode
    if test_mode == "visual":
        setup_visual_test()
    else:
        run_automated_test()

# Create a test character instance
func create_test_character() -> PlayerCharacter:
    var character = PlayerCharacter.new()
    character.player_name = "Test Character"
    character.skin_color = Color(1.0, 0.8, 0.6)
    character.hair_style = 0
    character.hair_color = Color(0.3, 0.2, 0.1)
    character.eye_color = Color(0.3, 0.5, 0.7)
    character.gender = "neutral"
    
    print("Created test character: " + character.player_name)
    return character

# Setup for visual testing with UI controls
func setup_visual_test():
    print("Setting up visual test")
    
    # Find or create 3D preview
    var model_scene = get_node_or_null("ModelViewer")
    if not model_scene:
        print("Creating model viewer")
        model_scene = Node3D.new()
        model_scene.name = "ModelViewer"
        add_child(model_scene)
    
    # Create character model controller
    model_controller = CharacterModelController.new()
    model_controller.name = "CharacterModelController"
    model_scene.add_child(model_controller)
    
    # Create a model holder
    var model_holder = Node3D.new()
    model_holder.name = "ModelHolder"
    model_controller.add_child(model_holder)
    
    # Create Camera
    var camera = Camera3D.new()
    camera.name = "Camera"
    camera.position = Vector3(0, 0, 2)
    camera.current = true
    model_scene.add_child(camera)
    
    # Create Light
    var light = DirectionalLight3D.new()
    light.name = "Light"
    light.position = Vector3(2, 2, 2)
    light.look_at(Vector3.ZERO, Vector3.UP)
    model_scene.add_child(light)
    
    # Create UI for testing
    create_test_ui()
    
    # Apply character data to model
    if model_controller:
        model_controller.model_ready.connect(self._on_model_ready)
        model_controller.apply_character_config(character_data)
    else:
        printerr("Error: model_controller not created")

# Create UI controls for visual testing
func create_test_ui():
    print("Creating test UI")
    
    # Create UI container
    var ui = Control.new()
    ui.name = "TestUI"
    ui.anchor_right = 1.0
    ui.anchor_bottom = 1.0
    add_child(ui)
    
    # Create UI elements
    var panel = Panel.new()
    panel.name = "ControlPanel"
    panel.anchor_top = 0.7
    panel.anchor_right = 1.0
    panel.anchor_bottom = 1.0
    ui.add_child(panel)
    
    var vbox = VBoxContainer.new()
    vbox.name = "Controls"
    vbox.anchor_right = 1.0
    vbox.anchor_bottom = 1.0
    vbox.position.x = 20
    vbox.position.y = 20
    vbox.size.x = -20
    vbox.size.y = -20
    panel.add_child(vbox)
    
    # Add sliders for testing appearance
    add_color_control(vbox, "Skin Color", character_data.skin_color, "_on_skin_color_changed")
    add_slider_control(vbox, "Hair Style", character_data.hair_style, 0, 4, "_on_hair_style_changed")
    add_color_control(vbox, "Hair Color", character_data.hair_color, "_on_hair_color_changed")
    add_color_control(vbox, "Eye Color", character_data.eye_color, "_on_eye_color_changed")
    
    # Add camera rotation control
    add_slider_control(vbox, "Camera Rotation", 0, 0, 360, "_on_camera_rotation_changed")
    
    # Add test result label
    var result_label = Label.new()
    result_label.name = "ResultLabel"
    result_label.text = "Test in progress..."
    vbox.add_child(result_label)
    
    ui_elements["result_label"] = result_label

# Add a color picker control to the UI
func add_color_control(parent, label_text, initial_color, callback):
    var hbox = HBoxContainer.new()
    hbox.name = label_text.replace(" ", "") + "Container"
    parent.add_child(hbox)
    
    var label = Label.new()
    label.name = "Label"
    label.text = label_text
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(label)
    
    var color_picker = ColorPickerButton.new()
    color_picker.name = label_text.replace(" ", "") + "Picker"
    color_picker.custom_minimum_size = Vector2(60, 30)
    color_picker.color = initial_color
    color_picker.color_changed.connect(Callable(self, callback))
    hbox.add_child(color_picker)
    
    ui_elements[label_text.replace(" ", "_").to_lower()] = color_picker

# Add a slider control to the UI
func add_slider_control(parent, label_text, initial_value, min_value, max_value, callback):
    var hbox = HBoxContainer.new()
    hbox.name = label_text.replace(" ", "") + "Container"
    parent.add_child(hbox)
    
    var label = Label.new()
    label.name = "Label"
    label.text = label_text
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(label)
    
    var slider = HSlider.new()
    slider.name = label_text.replace(" ", "") + "Slider"
    slider.min_value = min_value
    slider.max_value = max_value
    slider.value = initial_value
    slider.step = 1
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    slider.value_changed.connect(Callable(self, callback))
    hbox.add_child(slider)
    
    var value_label = Label.new()
    value_label.name = "ValueLabel"
    value_label.text = str(initial_value)
    value_label.custom_minimum_size = Vector2(40, 0)
    hbox.add_child(value_label)
    
    ui_elements[label_text.replace(" ", "_").to_lower()] = slider
    ui_elements[label_text.replace(" ", "_").to_lower() + "_value"] = value_label

# Run automated testing
func run_automated_test():
    print("Running automated test")
    
    # Create a simple test environment
    var test_env = Node3D.new()
    test_env.name = "TestEnvironment"
    add_child(test_env)
    
    # Create character model controller
    model_controller = CharacterModelController.new()
    model_controller.name = "CharacterModelController"
    test_env.add_child(model_controller)
    
    # Create a model holder
    var model_holder = Node3D.new()
    model_holder.name = "ModelHolder"
    model_controller.add_child(model_holder)
    
    # Connect to model ready signal
    model_controller.model_ready.connect(self._on_model_ready)
    
    # Apply character data to model
    model_controller.apply_character_config(character_data)
    
    # Test various appearance combinations
    await get_tree().create_timer(1.0).timeout
    
    # Test different skin colors
    print("Testing skin color changes")
    var skin_colors = [
        Color(1.0, 0.8, 0.6),  # Default
        Color(0.8, 0.6, 0.4),  # Darker
        Color(1.0, 0.9, 0.8)   # Lighter
    ]
    
    for color in skin_colors:
        model_controller.set_skin_color(color)
        await get_tree().create_timer(0.5).timeout
    
    # Test different hair styles
    print("Testing hair style changes")
    for style in range(5):  # 5 hair styles
        model_controller.set_hair_style(style)
        await get_tree().create_timer(0.5).timeout
    
    # Test different hair colors
    print("Testing hair color changes")
    var hair_colors = [
        Color(0.3, 0.2, 0.1),  # Brown
        Color(0.9, 0.9, 0.0),  # Blonde
        Color(0.1, 0.1, 0.1)   # Black
    ]
    
    for color in hair_colors:
        model_controller.set_hair_color(color)
        await get_tree().create_timer(0.5).timeout
    
    # Test different eye colors
    print("Testing eye color changes")
    var eye_colors = [
        Color(0.3, 0.5, 0.7),  # Blue
        Color(0.3, 0.6, 0.3),  # Green
        Color(0.6, 0.3, 0.1)   # Brown
    ]
    
    for color in eye_colors:
        model_controller.set_eye_color(color)
        await get_tree().create_timer(0.5).timeout
    
    # Report test results
    print("Automated test completed successfully")
    
    # Clean up
    test_env.queue_free()

# UI callback handlers
func _on_skin_color_changed(color):
    if model_controller:
        model_controller.set_skin_color(color)
        character_data.skin_color = color

func _on_hair_style_changed(value):
    if model_controller:
        model_controller.set_hair_style(int(value))
        character_data.hair_style = int(value)
        
    # Update value label
    if "hair_style_value" in ui_elements:
        ui_elements["hair_style_value"].text = str(int(value))

func _on_hair_color_changed(color):
    if model_controller:
        model_controller.set_hair_color(color)
        character_data.hair_color = color

func _on_eye_color_changed(color):
    if model_controller:
        model_controller.set_eye_color(color)
        character_data.eye_color = color

func _on_camera_rotation_changed(value):
    var camera = get_node_or_null("ModelViewer/Camera")
    if camera:
        var angle = deg_to_rad(value)
        var distance = 2
        var height = 0
        
        camera.position = Vector3(sin(angle) * distance, height, cos(angle) * distance)
        camera.look_at(Vector3(0, 0, 0), Vector3.UP)
    
    # Update value label
    if "camera_rotation_value" in ui_elements:
        ui_elements["camera_rotation_value"].text = str(int(value))

# Signal handlers
func _on_model_ready():
    print("Model loaded successfully")
    
    if "result_label" in ui_elements:
        ui_elements["result_label"].text = "Model loaded successfully"
    
    # Test model appearance controls
    test_appearance_controls()

# Test the model appearance controls
func test_appearance_controls():
    if not model_controller:
        return
    
    print("Testing appearance controls")
    
    # Test various appearance combinations
    var test_sequence = [
        func(): model_controller.set_skin_color(Color(0.8, 0.6, 0.4)),
        func(): model_controller.set_hair_style(1),
        func(): model_controller.set_hair_color(Color(0.7, 0.5, 0.0)),
        func(): model_controller.set_eye_color(Color(0.1, 0.5, 0.1)),
        func(): model_controller.set_skin_color(Color(1.0, 0.8, 0.6))
    ]
    
    # Run sequence with delays
    run_test_sequence(test_sequence)

# Helper to run a sequence of test functions with delays
func run_test_sequence(sequence, index = 0):
    if index >= sequence.size():
        print("Test sequence completed")
        return
    
    # Run the current test function
    sequence[index].call()
    
    # Schedule the next function with a delay
    await get_tree().create_timer(0.5).timeout
    run_test_sequence(sequence, index + 1)
