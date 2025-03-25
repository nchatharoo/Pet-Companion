extends CharacterBody3D

class_name PlayerCharacter

# Player appearance
@export var skin_color: Color = Color(1.0, 0.8, 0.7)
@export var hair_color: Color = Color(0.2, 0.1, 0.0)
@export var eye_color: Color = Color(0.3, 0.5, 0.7)
@export var hairstyle: int = 0

# Player attributes
@export var player_name: String = "Player"
@export var movement_speed: float = 5.0

# References
@onready var animation_player = $AnimationPlayer

# Movement
var input_dir: Vector2 = Vector2.ZERO
var current_velocity: Vector3 = Vector3.ZERO

func _ready():
    # Initialize character appearance
    update_appearance()

func _physics_process(delta):
    # Handle movement
    handle_movement(delta)
    
    # Handle animations
    handle_animations()
    
func handle_movement(delta: float) -> void:
    # Get movement input
    input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    
    # Calculate velocity
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * movement_speed
        velocity.z = direction.z * movement_speed
    else:
        velocity.x = move_toward(velocity.x, 0, movement_speed)
        velocity.z = move_toward(velocity.z, 0, movement_speed)
    
    # Apply movement
    move_and_slide()
    
func handle_animations() -> void:
    # If we had animations, we would change them based on movement
    if input_dir != Vector2.ZERO:
        # Play walking animation
        pass
    else:
        # Play idle animation
        pass
        
func update_appearance() -> void:
    # Update character appearance based on current settings
    # This would normally update materials, mesh instances, etc.
    pass
    
func serialize() -> Dictionary:
    # Serialize player data for saving
    return {
        "name": player_name,
        "skin_color": {
            "r": skin_color.r,
            "g": skin_color.g,
            "b": skin_color.b
        },
        "hair_color": {
            "r": hair_color.r,
            "g": hair_color.g,
            "b": hair_color.b
        },
        "eye_color": {
            "r": eye_color.r,
            "g": eye_color.g,
            "b": eye_color.b
        },
        "hairstyle": hairstyle
    }
    
func deserialize(data: Dictionary) -> void:
    # Deserialize player data from save
    if data.has("name"):
        player_name = data["name"]
        
    if data.has("skin_color"):
        skin_color = Color(
            data["skin_color"]["r"],
            data["skin_color"]["g"],
            data["skin_color"]["b"]
        )
        
    if data.has("hair_color"):
        hair_color = Color(
            data["hair_color"]["r"],
            data["hair_color"]["g"],
            data["hair_color"]["b"]
        )
        
    if data.has("eye_color"):
        eye_color = Color(
            data["eye_color"]["r"],
            data["eye_color"]["g"],
            data["eye_color"]["b"]
        )
        
    if data.has("hairstyle"):
        hairstyle = data["hairstyle"]
        
    # Update visual appearance
    update_appearance()
