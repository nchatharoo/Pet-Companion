extends Node

# Temporay test script

func _ready():
    var viewport_container = $Character_Creation/CharacterViewportContainer
    var viewport = viewport_container.get_node("CharacterViewport")
    
    print("Testing viewport setup")
    print("Viewport container found: ", viewport_container != null)
    print("Viewport found: ", viewport != null)
    
    # Add a simple test mesh to verify viewport is working
    var test_mesh = CSGSphere3D.new()
    test_mesh.radius = 0.5
    test_mesh.material = StandardMaterial3D.new()
    test_mesh.material.albedo_color = Color(1, 0.5, 0.3)
    
    var test_node = Node3D.new()
    test_node.add_child(test_mesh)
    test_node.position = Vector3(0, 1, 0)
    
    viewport.add_child(test_node)
    
    print("Added test sphere to viewport")
