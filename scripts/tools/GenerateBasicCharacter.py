import bpy
import os
import math

"""
GenerateBasicCharacter.py - Script for generating a basic character model for Pet Companion
This script creates a simple stylized human character with a clean topology
suitable for the character creator.
"""

def create_basic_character():
    # Clear existing objects
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    
    # Create a simple humanoid base mesh
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.2, location=(0, 0, 0.7))
    head = bpy.context.active_object
    head.name = "character_head"
    
    bpy.ops.mesh.primitive_cylinder_add(radius=0.15, depth=0.4, location=(0, 0, 0.4))
    torso = bpy.context.active_object
    torso.name = "character_torso"
    
    # Create arms
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.3, location=(0.2, 0, 0.4))
    arm_upper_r = bpy.context.active_object
    arm_upper_r.name = "character_arm_upper_r"
    arm_upper_r.rotation_euler = (0, math.radians(90), 0)
    
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.3, location=(0.45, 0, 0.4))
    arm_lower_r = bpy.context.active_object
    arm_lower_r.name = "character_arm_lower_r"
    arm_lower_r.rotation_euler = (0, math.radians(90), 0)
    
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.3, location=(-0.2, 0, 0.4))
    arm_upper_l = bpy.context.active_object
    arm_upper_l.name = "character_arm_upper_l"
    arm_upper_l.rotation_euler = (0, math.radians(90), 0)
    
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.3, location=(-0.45, 0, 0.4))
    arm_lower_l = bpy.context.active_object
    arm_lower_l.name = "character_arm_lower_l"
    arm_lower_l.rotation_euler = (0, math.radians(90), 0)
    
    # Create legs
    bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.4, location=(0.1, 0, -0.2))
    leg_upper_r = bpy.context.active_object
    leg_upper_r.name = "character_leg_upper_r"
    
    bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.4, location=(0.1, 0, -0.6))
    leg_lower_r = bpy.context.active_object
    leg_lower_r.name = "character_leg_lower_r"
    
    bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.4, location=(-0.1, 0, -0.2))
    leg_upper_l = bpy.context.active_object
    leg_upper_l.name = "character_leg_upper_l"
    
    bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.4, location=(-0.1, 0, -0.6))
    leg_lower_l = bpy.context.active_object
    leg_lower_l.name = "character_leg_lower_l"
    
    # Create a simple armature
    bpy.ops.object.armature_add(location=(0, 0, 0))
    armature = bpy.context.active_object
    armature.name = "character_armature"
    
    # Enter edit mode to create bones
    bpy.ops.object.mode_set(mode='EDIT')
    
    # Get edit bones
    edit_bones = armature.data.edit_bones
    
    # Clear default bone
    for bone in edit_bones:
        edit_bones.remove(bone)
    
    # Create root bone
    root = edit_bones.new('root')
    root.head = (0, 0, 0)
    root.tail = (0, 0, 0.1)
    
    # Create spine
    spine = edit_bones.new('spine')
    spine.head = (0, 0, 0.1)
    spine.tail = (0, 0, 0.4)
    spine.parent = root
    
    # Create head
    head_bone = edit_bones.new('head')
    head_bone.head = (0, 0, 0.4)
    head_bone.tail = (0, 0, 0.7)
    head_bone.parent = spine
    
    # Create arm bones
    arm_upper_r_bone = edit_bones.new('arm_upper_r')
    arm_upper_r_bone.head = (0.1, 0, 0.4)
    arm_upper_r_bone.tail = (0.3, 0, 0.4)
    arm_upper_r_bone.parent = spine
    
    arm_lower_r_bone = edit_bones.new('arm_lower_r')
    arm_lower_r_bone.head = (0.3, 0, 0.4)
    arm_lower_r_bone.tail = (0.5, 0, 0.4)
    arm_lower_r_bone.parent = arm_upper_r_bone
    
    arm_upper_l_bone = edit_bones.new('arm_upper_l')
    arm_upper_l_bone.head = (-0.1, 0, 0.4)
    arm_upper_l_bone.tail = (-0.3, 0, 0.4)
    arm_upper_l_bone.parent = spine
    
    arm_lower_l_bone = edit_bones.new('arm_lower_l')
    arm_lower_l_bone.head = (-0.3, 0, 0.4)
    arm_lower_l_bone.tail = (-0.5, 0, 0.4)
    arm_lower_l_bone.parent = arm_upper_l_bone
    
    # Create leg bones
    leg_upper_r_bone = edit_bones.new('leg_upper_r')
    leg_upper_r_bone.head = (0.1, 0, 0)
    leg_upper_r_bone.tail = (0.1, 0, -0.4)
    leg_upper_r_bone.parent = root
    
    leg_lower_r_bone = edit_bones.new('leg_lower_r')
    leg_lower_r_bone.head = (0.1, 0, -0.4)
    leg_lower_r_bone.tail = (0.1, 0, -0.8)
    leg_lower_r_bone.parent = leg_upper_r_bone
    
    leg_upper_l_bone = edit_bones.new('leg_upper_l')
    leg_upper_l_bone.head = (-0.1, 0, 0)
    leg_upper_l_bone.tail = (-0.1, 0, -0.4)
    leg_upper_l_bone.parent = root
    
    leg_lower_l_bone = edit_bones.new('leg_lower_l')
    leg_lower_l_bone.head = (-0.1, 0, -0.4)
    leg_lower_l_bone.tail = (-0.1, 0, -0.8)
    leg_lower_l_bone.parent = leg_upper_l_bone
    
    # Exit edit mode
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Create a collection for character parts
    character_collection = bpy.data.collections.new("Character")
    bpy.context.scene.collection.children.link(character_collection)
    
    # Create materials
    skin_material = bpy.data.materials.new("Character_Skin")
    skin_material.diffuse_color = (0.8, 0.6, 0.5, 1.0)
    
    # Assign materials and parent to armature
    parts = [head, torso, arm_upper_r, arm_lower_r, arm_upper_l, arm_lower_l,
             leg_upper_r, leg_lower_r, leg_upper_l, leg_lower_l]
    
    for part in parts:
        # Unlink from current collection
        for collection in part.users_collection:
            collection.objects.unlink(part)
        
        # Link to character collection
        character_collection.objects.link(part)
        
        # Assign material
        if len(part.data.materials) == 0:
            part.data.materials.append(skin_material)
        else:
            part.data.materials[0] = skin_material
        
        # Parent to armature
        part.parent = armature
        
        # Add armature modifier
        mod = part.modifiers.new(name="Armature", type='ARMATURE')
        mod.object = armature
    
    # Join all mesh parts
    bpy.ops.object.select_all(action='DESELECT')
    for part in parts:
        part.select_set(True)
    
    bpy.context.view_layer.objects.active = head
    bpy.ops.object.join()
    
    # Rename the joined mesh
    bpy.context.active_object.name = "character_mesh"
    
    return bpy.context.active_object, armature

def create_hair_styles():
    # Placeholder function to create basic hair styles
    styles = []
    
    # Create a simple hairstyle collection
    hair_collection = bpy.data.collections.new("HairStyles")
    bpy.context.scene.collection.children.link(hair_collection)
    
    # Style 1: Short hair
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(0, 0, 0.7))
    hair1 = bpy.context.active_object
    hair1.name = "hair_style1"
    hair1.scale = (1, 1, 0.7)  # Flatten slightly
    
    # Add material
    hair_material = bpy.data.materials.new("Character_Hair")
    hair_material.diffuse_color = (0.1, 0.05, 0.01, 1.0)  # Dark brown
    
    hair1.data.materials.append(hair_material)
    
    # Unlink from current collection
    for collection in hair1.users_collection:
        collection.objects.unlink(hair1)
    
    # Link to hair collection
    hair_collection.objects.link(hair1)
    
    styles.append(hair1)
    
    # Style 2: Longer hair
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.24, location=(0, 0, 0.7))
    hair2 = bpy.context.active_object
    hair2.name = "hair_style2"
    hair2.scale = (1, 1, 0.8)
    
    # Modify to make it longer
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='DESELECT')
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Select bottom vertices
    for v in hair2.data.vertices:
        if v.co.z < 0.6:
            v.select = True
    
    # Enter edit mode and move selected vertices down
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.transform.translate(value=(0, 0, -0.1))
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Add material
    hair2.data.materials.append(hair_material)
    
    # Unlink from current collection
    for collection in hair2.users_collection:
        collection.objects.unlink(hair2)
    
    # Link to hair collection
    hair_collection.objects.link(hair2)
    
    styles.append(hair2)
    
    return styles

def setup_character_for_export(character_mesh, armature):
    # Set up the character for export to Godot
    
    # Make sure mesh is selected
    bpy.ops.object.select_all(action='DESELECT')
    character_mesh.select_set(True)
    bpy.context.view_layer.objects.active = character_mesh
    
    # Apply any modifiers
    for modifier in character_mesh.modifiers:
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    
    # Create UV maps
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')
    
    # Set custom properties for Godot export
    character_mesh["godot_path"] = "res://assets/models/characters/placeholders/character_base.glb"
    
    # Set up a root empty to export both mesh and armature
    bpy.ops.object.empty_add(type='PLAIN_AXES', location=(0, 0, 0))
    root_empty = bpy.context.active_object
    root_empty.name = "character_base"
    
    # Parent mesh and armature to root
    character_mesh.parent = root_empty
    armature.parent = root_empty
    
    return root_empty

def export_models(root_object, export_path):
    # Export the model to Godot-compatible format
    bpy.ops.object.select_all(action='DESELECT')
    root_object.select_set(True)
    
    # Export as GLTF
    bpy.ops.export_scene.gltf(
        filepath=export_path,
        export_format='GLB',
        use_selection=True,
        export_animations=True,
        export_skins=True,
        export_morph=True
    )
    
    print(f"Model exported to {export_path}")

# Main execution
if __name__ == "__main__":
    # Create the character
    character_mesh, armature = create_basic_character()
    
    # Create hair styles
    hair_styles = create_hair_styles()
    
    # Setup for export
    root_object = setup_character_for_export(character_mesh, armature)
    
    # Export path
    export_path = "C:/Users/dalak/Documents/Pet Companion/assets/models/characters/placeholders/character_base.glb"
    
    # Export the model
    export_models(root_object, export_path)
    
    # Export hair styles
    for i, hair in enumerate(hair_styles):
        # Setup for export
        bpy.ops.object.select_all(action='DESELECT')
        hair.select_set(True)
        
        # Export path for hair
        hair_export_path = f"C:/Users/dalak/Documents/Pet Companion/assets/models/characters/placeholders/hair_style{i+1}.glb"
        
        # Export
        bpy.ops.export_scene.gltf(
            filepath=hair_export_path,
            export_format='GLB',
            use_selection=True
        )
        
        print(f"Hair style {i+1} exported to {hair_export_path}")
    
    print("All models exported successfully")
