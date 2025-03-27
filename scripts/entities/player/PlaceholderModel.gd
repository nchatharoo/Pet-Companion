extends Node3D

# This is a placeholder script to create a simple character model
# for testing the character creation scene

func _ready():
    # Create a simple character model for testing
    _create_placeholder_model()

func _create_placeholder_model():
    # Create a body mesh
    var body_mesh = CylinderMesh.new()
    body_mesh.top_radius = 0.25
    body_mesh.bottom_radius = 0.15
    body_mesh.height = 1.0
    
    # Create a head mesh
    var head_mesh = SphereMesh.new()
    head_mesh.radius = 0.25
    
    # Create body mesh instance
    var body = MeshInstance3D.new()
    body.name = "Body"
    body.mesh = body_mesh
    
    # Create a body material
    var body_material = StandardMaterial3D.new()
    body_material.resource_name = "Character_Skin"
    body_material.albedo_color = Color(1.0, 0.8, 0.6)  # Default skin tone
    body.material_override = body_material
    
    # Create head mesh instance
    var head = MeshInstance3D.new()
    head.name = "Head"
    head.mesh = head_mesh
    head.position.y = 0.75  # Position head on top of body
    
    # Use the same material for the head
    head.material_override = body_material
    
    # Create eyes
    var eye_mesh = SphereMesh.new()
    eye_mesh.radius = 0.05
    
    # Left eye
    var left_eye = MeshInstance3D.new()
    left_eye.name = "LeftEye"
    left_eye.mesh = eye_mesh
    left_eye.position = Vector3(-0.1, 0.8, 0.2)
    
    # Right eye
    var right_eye = MeshInstance3D.new()
    right_eye.name = "RightEye"
    right_eye.mesh = eye_mesh
    right_eye.position = Vector3(0.1, 0.8, 0.2)
    
    # Eye material
    var eye_material = StandardMaterial3D.new()
    eye_material.resource_name = "Character_Eyes"
    eye_material.albedo_color = Color(0.3, 0.5, 0.7)  # Default blue
    left_eye.material_override = eye_material
    right_eye.material_override = eye_material
    
    # Create a root node for the character
    var character_base = Node3D.new()
    character_base.name = "character_base_body"
    
    # Add all parts to the character
    character_base.add_child(body)
    character_base.add_child(head)
    character_base.add_child(left_eye)
    character_base.add_child(right_eye)
    
    # Add character to scene
    add_child(character_base)
    
    # Create a simple hair model
    _create_placeholder_hair()

func _create_placeholder_hair():
    # Create a hair mesh
    var hair_mesh = SphereMesh.new()
    hair_mesh.radius = 0.28
    hair_mesh.height = 0.38
    
    # Create mesh instance
    var hair = MeshInstance3D.new()
    hair.mesh = hair_mesh
    hair.position.y = 0.75  # Position on top of head
    
    # Hair material
    var hair_material = StandardMaterial3D.new()
    hair_material.resource_name = "Character_Hair"
    hair_material.albedo_color = Color(0.3, 0.2, 0.1)  # Default brown
    hair.material_override = hair_material
    
    # Create a root node for the hair
    var hair_model = Node3D.new()
    hair_model.name = "hair_model"
    hair_model.add_child(hair)
    
    # Add to scene
    add_child(hair_model)
