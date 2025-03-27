class_name IsometricCamera
extends Camera3D

# Camera settings
@export var target_node_path: NodePath
@export var distance: float = 10.0
@export var height: float = 8.0
@export var angle: float = 45.0  # Degrees
@export var smoothing: float = 5.0

# Rotation settings
@export var can_rotate: bool = true
@export var rotation_speed: float = 90.0  # Degrees per second
@export var current_rotation: float = 0.0

# Zoom settings
@export var can_zoom: bool = true
@export var min_zoom: float = 7.0
@export var max_zoom: float = 15.0
@export var zoom_speed: float = 1.0

# Boundaries
@export var use_boundaries: bool = true
@export var boundary_min: Vector3 = Vector3(-50, 0, -50)
@export var boundary_max: Vector3 = Vector3(50, 0, 50)

# Private variables
var _target_position: Vector3 = Vector3.ZERO
var _current_distance: float
var _target: Node3D = null

func _ready():
	# Initialize camera
	_current_distance = distance
	
	# Get target if specified
	if target_node_path:
		_target = get_node(target_node_path)
	
	# Set projection to orthogonal for true isometric
	projection = PROJECTION_ORTHOGONAL
	size = distance
	
	# Set initial position
	_update_camera_position()

func _process(delta):
	# Update target position
	if _target:
		_target_position = _target.global_position
	
	# Apply boundaries if enabled
	if use_boundaries:
		_target_position.x = clamp(_target_position.x, boundary_min.x, boundary_max.x)
		_target_position.z = clamp(_target_position.z, boundary_min.z, boundary_max.z)
	
	# Smooth camera movement
	if smoothing > 0:
		var target_cam_pos = _calculate_camera_position(_target_position)
		global_position = global_position.lerp(target_cam_pos, delta * smoothing)
		
		# Always look at the target
		look_at(_target_position)
	else:
		_update_camera_position()

func _unhandled_input(event):
	# Camera rotation
	if can_rotate:
		if event.is_action_pressed("camera_rotate_left"):
			current_rotation -= 90.0
		elif event.is_action_pressed("camera_rotate_right"):
			current_rotation += 90.0
	
	# Camera zoom
	if can_zoom:
		if event.is_action("camera_zoom_in"):
			_current_distance = clamp(_current_distance - zoom_speed, min_zoom, max_zoom)
			size = _current_distance
		elif event.is_action("camera_zoom_out"):
			_current_distance = clamp(_current_distance + zoom_speed, min_zoom, max_zoom)
			size = _current_distance

func _update_camera_position():
	global_position = _calculate_camera_position(_target_position)
	look_at(_target_position)

func _calculate_camera_position(target_pos: Vector3) -> Vector3:
	# Convert angle to radians
	var rad_angle = deg_to_rad(angle)
	var rad_rotation = deg_to_rad(current_rotation)
	
	# Calculate camera position relative to target
	var cam_x = target_pos.x + _current_distance * sin(rad_rotation) * cos(rad_angle)
	var cam_y = target_pos.y + height
	var cam_z = target_pos.z + _current_distance * cos(rad_rotation) * cos(rad_angle)
	
	return Vector3(cam_x, cam_y, cam_z)

func set_target(new_target: Node3D):
	_target = new_target

func set_boundaries(min_bounds: Vector3, max_bounds: Vector3):
	boundary_min = min_bounds
	boundary_max = max_bounds
	use_boundaries = true
