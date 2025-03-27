import bpy
import os
import sys
import math

"""
CharacterModelProcessor.py - Script for processing character models for Pet Companion game
This script performs the following operations:
1. Cleans up and optimizes topology
2. Sets up a standardized rig
3. Prepares UV maps for texture customization
4. Exports the model in GLTF format for Godot
"""

class CharacterModelProcessor:
    def __init__(self, model_name, target_triangle_count=3000):
        self.model_name = model_name
        self.target_triangle_count = target_triangle_count
        self.character_mesh = None
        self.armature = None
        
    def process_model(self):
        """Main processing pipeline"""
        print(f"Processing model: {self.model_name}")
        
        # Select the character mesh
        self.find_character_mesh()
        
        if not self.character_mesh:
            print("Error: Character mesh not found")
            return False
            
        # Clean up mesh
        self.clean_mesh()
        
        # Optimize topology
        self.optimize_topology()
        
        # Set up material slots
        self.setup_materials()
        
        # Create UV maps
        self.create_uv_maps()
        
        # Create a simple rig
        self.create_rig()
        
        # Prepare for export
        self.prepare_for_export()
        
        print(f"Processing completed for {self.model_name}")
        return True
        
    def find_character_mesh(self):
        """Find the main character mesh in the scene"""
        for obj in bpy.data.objects:
            if obj.type == 'MESH' and obj.name.lower().find('character') >= 0:
                self.character_mesh = obj
                return
                
        # If no mesh with 'character' in the name, take the first mesh
        for obj in bpy.data.objects:
            if obj.type == 'MESH':
                self.character_mesh = obj
                return
    
    def clean_mesh(self):
        """Clean up the mesh: remove doubles, degenerate faces, etc."""
        print("Cleaning mesh...")
        
        # Select the mesh
        bpy.ops.object.select_all(action='DESELECT')
        self.character_mesh.select_set(True)
        bpy.context.view_layer.objects.active = self.character_mesh
        
        # Enter edit mode
        bpy.ops.object.mode_set(mode='EDIT')
        
        # Select all vertices
        bpy.ops.mesh.select_all(action='SELECT')
        
        # Remove doubles
        bpy.ops.mesh.remove_doubles(threshold=0.0001)
        
        # Recalculate normals
        bpy.ops.mesh.normals_make_consistent(inside=False)
        
        # Return to object mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        print(f"Mesh cleaned. Vertices: {len(self.character_mesh.data.vertices)}, Faces: {len(self.character_mesh.data.polygons)}")
    
    def optimize_topology(self):
        """Optimize the topology to meet the target triangle count"""
        print("Optimizing topology...")
        
        # Current face count
        face_count = len(self.character_mesh.data.polygons)
        
        # Calculate target face count (assuming triangles)
        target_face_count = self.target_triangle_count / 3
        
        # If the mesh is already below the target count, we're done
        if face_count <= target_face_count:
            print(f"Mesh already optimized. Face count: {face_count}")
            return
            
        # Calculate ratio for decimation
        ratio = target_face_count / face_count
        
        # Add a decimate modifier
        decimate = self.character_mesh.modifiers.new(name="Decimate", type='DECIMATE')
        decimate.ratio = ratio
        decimate.use_collapse_triangulate = True
        
        # Apply the modifier
        bpy.context.view_layer.objects.active = self.character_mesh
        bpy.ops.object.modifier_apply(modifier="Decimate")
        
        print(f"Topology optimized. New face count: {len(self.character_mesh.data.polygons)}")
    
    def setup_materials(self):
        """Set up material slots for skin, hair, eyes"""
        print("Setting up materials...")
        
        # Clear existing materials
        self.character_mesh.data.materials.clear()
        
        # Create basic materials
        skin_mat = bpy.data.materials.new(name="Character_Skin")
        skin_mat.use_nodes = True
        
        hair_mat = bpy.data.materials.new(name="Character_Hair")
        hair_mat.use_nodes = True
        
        eyes_mat = bpy.data.materials.new(name="Character_Eyes")
        eyes_mat.use_nodes = True
        
        # Add materials to the mesh
        self.character_mesh.data.materials.append(skin_mat)
        self.character_mesh.data.materials.append(hair_mat)
        self.character_mesh.data.materials.append(eyes_mat)
        
        print("Materials set up")
    
    def create_uv_maps(self):
        """Create and optimize UV maps"""
        print("Creating UV maps...")
        
        # Select the mesh
        bpy.ops.object.select_all(action='DESELECT')
        self.character_mesh.select_set(True)
        bpy.context.view_layer.objects.active = self.character_mesh
        
        # Enter edit mode
        bpy.ops.object.mode_set(mode='EDIT')
        
        # Select all vertices
        bpy.ops.mesh.select_all(action='SELECT')
        
        # Create smart UV unwrap
        bpy.ops.uv.smart_project(angle_limit=66.0, island_margin=0.02)
        
        # Return to object mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        print("UV maps created")
    
    def create_rig(self):
        """Create a simple armature for the character"""
        print("Creating rig...")
        
        # Create armature
        armature = bpy.data.armatures.new('Character_Armature')
        self.armature = bpy.data.objects.new('Character_Rig', armature)
        bpy.context.collection.objects.link(self.armature)
        
        # Make armature active and enter edit mode
        bpy.context.view_layer.objects.active = self.armature
        bpy.ops.object.mode_set(mode='EDIT')
        
        # Get armature edit data
        edit_bones = self.armature.data.edit_bones
        
        # Create a simple humanoid skeleton
        # Root bone
        root = edit_bones.new('root')
        root.head = (0, 0, 0)
        root.tail = (0, 0, 0.1)
        
        # Spine bones
        spine = edit_bones.new('spine')
        spine.head = (0, 0, 0.1)
        spine.tail = (0, 0, 0.4)
        spine.parent = root
        
        spine1 = edit_bones.new('spine.001')
        spine1.head = (0, 0, 0.4)
        spine1.tail = (0, 0, 0.7)
        spine1.parent = spine
        
        # Head bones
        head = edit_bones.new('head')
        head.head = (0, 0, 0.7)
        head.tail = (0, 0, 0.9)
        head.parent = spine1
        
        # Arm bones
        shoulder_l = edit_bones.new('shoulder.L')
        shoulder_l.head = (0, 0, 0.7)
        shoulder_l.tail = (0.2, 0, 0.7)
        shoulder_l.parent = spine1
        
        arm_l = edit_bones.new('arm.L')
        arm_l.head = (0.2, 0, 0.7)
        arm_l.tail = (0.5, 0, 0.7)
        arm_l.parent = shoulder_l
        
        hand_l = edit_bones.new('hand.L')
        hand_l.head = (0.5, 0, 0.7)
        hand_l.tail = (0.6, 0, 0.7)
        hand_l.parent = arm_l
        
        shoulder_r = edit_bones.new('shoulder.R')
        shoulder_r.head = (0, 0, 0.7)
        shoulder_r.tail = (-0.2, 0, 0.7)
        shoulder_r.parent = spine1
        
        arm_r = edit_bones.new('arm.R')
        arm_r.head = (-0.2, 0, 0.7)
        arm_r.tail = (-0.5, 0, 0.7)
        arm_r.parent = shoulder_r
        
        hand_r = edit_bones.new('hand.R')
        hand_r.head = (-0.5, 0, 0.7)
        hand_r.tail = (-0.6, 0, 0.7)
        hand_r.parent = arm_r
        
        # Leg bones
        hip_l = edit_bones.new('hip.L')
        hip_l.head = (0, 0, 0.1)
        hip_l.tail = (0.1, 0, 0)
        hip_l.parent = root
        
        leg_l = edit_bones.new('leg.L')
        leg_l.head = (0.1, 0, 0)
        leg_l.tail = (0.1, 0, -0.5)
        leg_l.parent = hip_l
        
        foot_l = edit_bones.new('foot.L')
        foot_l.head = (0.1, 0, -0.5)
        foot_l.tail = (0.1, 0.1, -0.5)
        foot_l.parent = leg_l
        
        hip_r = edit_bones.new('hip.R')
        hip_r.head = (0, 0, 0.1)
        hip_r.tail = (-0.1, 0, 0)
        hip_r.parent = root
        
        leg_r = edit_bones.new('leg.R')
        leg_r.head = (-0.1, 0, 0)
        leg_r.tail = (-0.1, 0, -0.5)
        leg_r.parent = hip_r
        
        foot_r = edit_bones.new('foot.R')
        foot_r.head = (-0.1, 0, -0.5)
        foot_r.tail = (-0.1, 0.1, -0.5)
        foot_r.parent = leg_r
        
        # Exit edit mode
        bpy.ops.object.mode_set(mode='OBJECT')
        
        # Add armature modifier to mesh
        mod = self.character_mesh.modifiers.new(name="Armature", type='ARMATURE')
        mod.object = self.armature
        
        # Parent mesh to armature
        self.character_mesh.parent = self.armature
        
        print("Rig created")
    
    def prepare_for_export(self):
        """Prepare the model for export to Godot"""
        print("Preparing for export...")
        
        # Set the armature to rest position
        self.armature.data.pose_position = 'REST'
        
        # Set export friendly names
        self.character_mesh.name = f"character_base_body"
        self.armature.name = f"character_base_rig"
        
        # Apply all transforms
        bpy.ops.object.select_all(action='DESELECT')
        self.character_mesh.select_set(True)
        self.armature.select_set(True)
        bpy.context.view_layer.objects.active = self.armature
        bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
        
        print("Model prepared for export")
    
    def export_model(self, export_path):
        """Export the model in GLTF format"""
        print(f"Exporting model to {export_path}...")
        
        # Select objects to export
        bpy.ops.object.select_all(action='DESELECT')
        self.character_mesh.select_set(True)
        self.armature.select_set(True)
        
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

# Example usage (can be used as a Blender script)
if __name__ == "__main__":
    # Get command line arguments if running from command line
    if len(sys.argv) > 1 and sys.argv[1] == "--background":
        # Blender passes its own args, look for custom args after "--"
        try:
            idx = sys.argv.index("--")
            model_name = sys.argv[idx + 1]
            export_path = sys.argv[idx + 2]
        except (ValueError, IndexError):
            model_name = "character_base"
            export_path = "//character_base.glb"
    else:
        # Default values when running in Blender UI
        model_name = "character_base"
        export_path = "//character_base.glb"
    
    # Process the model
    processor = CharacterModelProcessor(model_name)
    success = processor.process_model()
    
    if success:
        processor.export_model(export_path)
        print("Character model processed and exported successfully")
    else:
        print("Failed to process character model")
