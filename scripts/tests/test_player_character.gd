# test_player_character.gd
extends Node

# Simple test script to verify PlayerCharacter serialization/deserialization

func _ready():
    print("Starting PlayerCharacter serialization test...")
    run_test()
    
func run_test():
    # Create a test character with specific values
    var original = PlayerCharacter.new(
        "Test Player",
        Color(0.8, 0.6, 0.4),
        2,
        Color(0.9, 0.8, 0.2),
        Color(0.1, 0.3, 0.9),
        "feminine"
    )
    original.model_path = "res://assets/models/characters/player_default.glb"
    
    print("Original character created:")
    print("- Name: ", original.player_name)
    print("- Skin Color: ", original.skin_color)
    print("- Hair Style: ", original.hair_style)
    print("- Hair Color: ", original.hair_color)
    print("- Eye Color: ", original.eye_color)
    print("- Gender: ", original.gender)
    print("- ID: ", original.character_id)
    
    # Serialize to dictionary
    var serialized = original.serialize()
    print("\nSerialized to JSON:")
    print(JSON.stringify(serialized, "  "))
    
    # Deserialize to new object
    var loaded = PlayerCharacter.deserialize(serialized)
    
    print("\nDeserialized back to PlayerCharacter:")
    print("- Name: ", loaded.player_name)
    print("- Skin Color: ", loaded.skin_color)
    print("- Hair Style: ", loaded.hair_style) 
    print("- Hair Color: ", loaded.hair_color)
    print("- Eye Color: ", loaded.eye_color)
    print("- Gender: ", loaded.gender)
    print("- ID: ", loaded.character_id)
    
    # Verify all attributes match
    var matches = true
    var mismatch_field = ""
    
    if original.player_name != loaded.player_name:
        matches = false
        mismatch_field = "player_name"
    elif original.character_id != loaded.character_id:
        matches = false
        mismatch_field = "character_id"
    elif original.skin_color != loaded.skin_color:
        matches = false
        mismatch_field = "skin_color"
    elif original.hair_style != loaded.hair_style:
        matches = false
        mismatch_field = "hair_style"
    elif original.hair_color != loaded.hair_color:
        matches = false
        mismatch_field = "hair_color"
    elif original.eye_color != loaded.eye_color:
        matches = false
        mismatch_field = "eye_color"
    elif original.gender != loaded.gender:
        matches = false
        mismatch_field = "gender"
    elif original.model_path != loaded.model_path:
        matches = false
        mismatch_field = "model_path"
    
    # Report test results
    if matches:
        print("\nTEST PASSED: All attributes match after serialization/deserialization")
    else:
        print("\nTEST FAILED: Mismatch in ", mismatch_field)
        print("Original: ", original.serialize())
        print("Loaded: ", loaded.serialize())
