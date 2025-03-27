extends Node3D
class_name CharacterModelController

# Signal emitted when the model is fully loaded and ready
signal model_ready

# Components
@onready var model_holder: Node3D = $ModelHolder

# Model parameters
var current_model_path: String = ""
var current_model_instance: Node3D = null

# Models paths - use placeholders until Hyper3D models are ready
const BASE_MODEL_PATH = "res://assets/models/characters/placeholders/character_base.glb" 
const HAIR_STYLES = [
    "res://assets/models/characters/placeholders/hair_style1.glb",
    "res://assets/models/characters/placeholders/hair_style2.glb",
    "res://assets/models/characters/placeholders/hair_style3.glb",
    "res://assets/models/characters/placeholders/hair_style4.glb",
    "res://assets/models/characters/placeholders/hair_style5.glb",
]

# Material node paths
const SKIN_MATERIAL_PATH = "character_base_body/Character_Skin"
const HAIR_MATERIAL_PATH = "hair_style/Character_Hair" 
const EYES_MATERIAL_PATH = "character_base_body/Character_Eyes"

# Current character appearance
var skin_color: Color = Color(1.0, 0.8, 0.6)
var hair_style: int = 0
var hair_color: Color = Color(0.3, 0.2, 0.1)
var eye_color: Color = Color(0.3, 0.5, 0.7)
var gender: String = "neutral"

# Reference to ResourceManager
var resource_manager = null

# Initialize the controller
func _ready():
    # Get ResourceManager singleton
    resource_manager = Engine.get_singleton("ResourceManager")
    if not resource_manager:
        push_error("ResourceManager singleton not found")
        return
    
    # Ensure model holder exists
    if not model_holder:
        push_error("ModelHolder node not found")
        model_holder = Node3D.new()
        model_holder.name = "ModelHolder"
        add_child(model_holder)
    
    # Load base model
    call_deferred("load_model", BASE_MODEL_PATH)

# Load a new model
func load_model(model_path: String) -> void:
    print("Loading character model: ", model_path)
    
    # Clear any existing model
    if current_model_instance:
        current_model_instance.queue_free()
        current_model_instance = null
    
    # Check if model exists
    if not ResourceLoader.exists(model_path):
        push_error("Model not found: " + model_path)
        return
    
    # Load the model resource
    var model_resource = ResourceLoader.load(model_path)
    if not model_resource:
        push_error("Failed to load model resource: " + model_path)
        return
    
    # Instantiate the model
    current_model_instance = model_resource.instantiate()
    if not current_model_instance:
        push_error("Failed to instantiate model")
        return
    
    # Add to scene
    model_holder.add_child(current_model_instance)
    current_model_path = model_path
    
    # Apply current appearance
    update_appearance()
    
    # Emit ready signal
    model_ready.emit()

# Update the appearance of the current model
func update_appearance() -> void:
    if not current_model_instance:
        return
    
    # Update skin color
    update_material_color(SKIN_MATERIAL_PATH, skin_color)
    
    # Update eye color
    update_material_color(EYES_MATERIAL_PATH, eye_color)
    
    # Load hair style if needed
    update_hair_style()

# Update a material's base color
func update_material_color(material_path: String, color: Color) -> void:
    if not current_model_instance:
        return
    
    # Find the node with the material
    var parts = material_path.split("/")
    if parts.size() < 2:
        push_error("Invalid material path format: " + material_path)
        return
    
    var node_path = parts[0]
    var material_name = parts[1]
    
    var target_node = current_model_instance.get_node_or_null(node_path)
    if not target_node:
        # Try finding the node by name (different structure in placeholder models)
        for child in current_model_instance.get_children():
            if child.name.to_lower().contains(node_path.to_lower()):
                target_node = child
                break
                
        if not target_node:
            push_warning("Node not found: " + node_path)
            return
    
    # Find material by name in the node's materials
    if target_node is MeshInstance3D:
        for i in range(target_node.get_surface_override_material_count()):
            var material = target_node.get_surface_override_material(i)
            if material and (material.resource_name == material_name or 
                            material.resource_name.to_lower().contains(material_name.to_lower())):
                # Update the base color
                if material is StandardMaterial3D:
                    material.albedo_color = color
                return
        
        # If not found in overrides, check mesh materials
        var mesh = target_node.mesh
        if mesh:
            for i in range(mesh.get_surface_count()):
                var material = mesh.surface_get_material(i)
                if material and (material.resource_name == material_name or 
                                material.resource_name.to_lower().contains(material_name.to_lower())):
                    # Create a new material instance to avoid changing the shared resource
                    var new_material = material.duplicate()
                    if new_material is StandardMaterial3D:
                        new_material.albedo_color = color
                    target_node.set_surface_override_material(i, new_material)
                    return
    
    push_warning("Material not found: " + material_name + " in node " + node_path)

# Update hair style
func update_hair_style() -> void:
    if not current_model_instance:
        return
    
    # Remove any existing hair
    var existing_hair = current_model_instance.get_node_or_null("hair_style")
    if existing_hair:
        existing_hair.queue_free()
    
    # Check if we have a valid hair style
    if hair_style < 0 or hair_style >= HAIR_STYLES.size():
        return
    
    # Load the hair model
    var hair_path = HAIR_STYLES[hair_style]
    if not ResourceLoader.exists(hair_path):
        push_warning("Hair model not found: " + hair_path)
        return
    
    var hair_resource = ResourceLoader.load(hair_path)
    if not hair_resource:
        push_error("Failed to load hair resource: " + hair_path)
        return
    
    var hair_instance = hair_resource.instantiate()
    if not hair_instance:
        push_error("Failed to instantiate hair model")
        return
    
    # Rename for consistency
    hair_instance.name = "hair_style"
    
    # Add to model
    current_model_instance.add_child(hair_instance)
    
    # Find and update hair material
    for child in hair_instance.get_children():
        if child is MeshInstance3D:
            for i in range(child.get_surface_override_material_count()):
                var material = child.get_surface_override_material(i)
                if material:
                    # Create a new material instance to avoid changing the shared resource
                    var new_material = material.duplicate()
                    if new_material is StandardMaterial3D:
                        new_material.albedo_color = hair_color
                    child.set_surface_override_material(i, new_material)
                    break
            
            # If still not updated, check mesh materials
            if child.mesh:
                for i in range(child.mesh.get_surface_count()):
                    var material = child.mesh.surface_get_material(i)
                    if material:
                        var new_material = material.duplicate()
                        if new_material is StandardMaterial3D:
                            new_material.albedo_color = hair_color
                        child.set_surface_override_material(i, new_material)
                        break

# Set skin color
func set_skin_color(color: Color) -> void:
    skin_color = color
    update_material_color(SKIN_MATERIAL_PATH, skin_color)

# Set hair style
func set_hair_style(style_index: int) -> void:
    hair_style = style_index
    update_hair_style()

# Set hair color
func set_hair_color(color: Color) -> void:
    hair_color = color
    
    # Find and update hair if it exists
    var hair_instance = current_model_instance.get_node_or_null("hair_style")
    if hair_instance:
        for child in hair_instance.get_children():
            if child is MeshInstance3D:
                for i in range(child.get_surface_override_material_count()):
                    var material = child.get_surface_override_material(i)
                    if material and material is StandardMaterial3D:
                        material.albedo_color = hair_color
                        return
                
                # If still not updated, check mesh materials
                if child.mesh:
                    for i in range(child.mesh.get_surface_count()):
                        var material = child.mesh.surface_get_material(i)
                        if material:
                            var new_material = material.duplicate()
                            if new_material is StandardMaterial3D:
                                new_material.albedo_color = hair_color
                            child.set_surface_override_material(i, new_material)
                            return

# Set eye color
func set_eye_color(color: Color) -> void:
    eye_color = color
    update_material_color(EYES_MATERIAL_PATH, eye_color)

# Set gender (affects body proportions)
func set_gender(new_gender: String) -> void:
    gender = new_gender
    # This would need to load a different base model
    # For now, we just record the selection

# Apply a full character configuration
func apply_character_config(character: PlayerCharacter) -> void:
    if not character:
        push_error("Invalid character data")
        return
    
    # Store appearance values
    skin_color = character.skin_color
    hair_style = character.hair_style
    hair_color = character.hair_color
    eye_color = character.eye_color
    gender = character.gender
    
    # Check if model is loaded
    if current_model_instance:
        # Apply all appearance settings
        update_appearance()
    else:
        # Load the model first
        load_model(BASE_MODEL_PATH)
