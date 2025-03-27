# PlayerCharacter.gd
class_name PlayerCharacter
extends Resource

# Player identity attributes
@export var player_name: String = ""
@export var character_id: String = ""  # Unique ID for save/load

# Appearance attributes
@export var skin_color: Color = Color(1.0, 0.8, 0.6)  # Default skin tone
@export var hair_style: int = 0  # Index into available hair styles
@export var hair_color: Color = Color(0.3, 0.2, 0.1)  # Default brown
@export var eye_color: Color = Color(0.3, 0.5, 0.7)  # Default blue
@export var gender: String = "neutral"  # "masculine", "feminine", "neutral"

# Metadata for save/load
@export var creation_date: Dictionary = {}
@export var last_saved: Dictionary = {}

# Reference to 3D model
@export var model_path: String = ""

# Signal emitted when appearance changes
signal appearance_changed

func _init(p_name: String = "", p_skin: Color = Color(1.0, 0.8, 0.6), 
		   p_hair_style: int = 0, p_hair_color: Color = Color(0.3, 0.2, 0.1),
		   p_eye_color: Color = Color(0.3, 0.5, 0.7), p_gender: String = "neutral"):
	player_name = p_name
	skin_color = p_skin
	hair_style = p_hair_style
	hair_color = p_hair_color
	eye_color = p_eye_color
	gender = p_gender
	character_id = generate_unique_id()
	creation_date = Time.get_datetime_dict_from_system()
	last_saved = Time.get_datetime_dict_from_system()

# Generate a unique ID for this character
func generate_unique_id() -> String:
	var time = Time.get_unix_time_from_system()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random = rng.randi()
	return str(time) + "_" + str(random)

# Update appearance and emit signal
func update_appearance(p_skin: Color, p_hair_style: int, p_hair_color: Color, p_eye_color: Color) -> void:
	skin_color = p_skin
	hair_style = p_hair_style
	hair_color = p_hair_color
	eye_color = p_eye_color
	appearance_changed.emit()

# Serialize character data to dictionary for saving
func serialize() -> Dictionary:
	return {
		"player_name": player_name,
		"character_id": character_id,
		"skin_color": {
			"r": skin_color.r,
			"g": skin_color.g,
			"b": skin_color.b,
			"a": skin_color.a
		},
		"hair_style": hair_style,
		"hair_color": {
			"r": hair_color.r,
			"g": hair_color.g,
			"b": hair_color.b,
			"a": hair_color.a
		},
		"eye_color": {
			"r": eye_color.r,
			"g": eye_color.g,
			"b": eye_color.b,
			"a": eye_color.a
		},
		"gender": gender,
		"creation_date": creation_date,
		"last_saved": Time.get_datetime_dict_from_system(),
		"model_path": model_path
	}

# Deserialize character data from dictionary when loading
static func deserialize(data: Dictionary) -> PlayerCharacter:
	var character = PlayerCharacter.new()
	
	character.player_name = data["player_name"]
	character.character_id = data["character_id"]
	
	# Reconstruct colors from serialized data
	var skin = data["skin_color"]
	character.skin_color = Color(skin["r"], skin["g"], skin["b"], skin["a"])
	
	character.hair_style = data["hair_style"]
	
	var hair = data["hair_color"]
	character.hair_color = Color(hair["r"], hair["g"], hair["b"], hair["a"])
	
	var eye = data["eye_color"]
	character.eye_color = Color(eye["r"], eye["g"], eye["b"], eye["a"])
	
	character.gender = data["gender"]
	character.creation_date = data["creation_date"]
	character.last_saved = data["last_saved"]
	character.model_path = data["model_path"]
	
	return character

# Load character model with ResourceManager
func load_model() -> Node3D:
	if model_path.is_empty():
		push_error("Cannot load model: empty model path")
		return null
		
	# Get ResourceManager singleton
	var resource_manager = Engine.get_singleton("ResourceManager")
	if not resource_manager:
		push_error("ResourceManager singleton not found")
		return null
		
	# Load the model resource
	var model_resource = resource_manager.load_resource(model_path)
	if not model_resource:
		push_error("Failed to load model resource: " + model_path)
		return null
		
	# Instantiate the model
	var model_instance = model_resource.instantiate()
	if not model_instance:
		push_error("Failed to instantiate model")
		return null
		
	# Apply appearance to the model
	apply_appearance_to_model(model_instance)
	return model_instance

# Apply current appearance settings to the character model
func apply_appearance_to_model(model: Node) -> void:
	# Find appearance controller component
	var appearance_controller = model.get_node_or_null("AppearanceController")
	if not appearance_controller:
		push_error("Model does not have an AppearanceController node")
		return
		
	# Apply appearance settings
	if appearance_controller.has_method("set_skin_color"):
		appearance_controller.set_skin_color(skin_color)
	
	if appearance_controller.has_method("set_hair_style"):
		appearance_controller.set_hair_style(hair_style)
	
	if appearance_controller.has_method("set_hair_color"):
		appearance_controller.set_hair_color(hair_color)
	
	if appearance_controller.has_method("set_eye_color"):
		appearance_controller.set_eye_color(eye_color)
