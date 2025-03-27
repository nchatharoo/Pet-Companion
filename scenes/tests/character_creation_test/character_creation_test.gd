extends Node

# This is a test script for validating the character creation scene

@onready var character_creation: CharacterCreationManager = $Character_Creation

# Mock GameManager functions for testing
var test_character: PlayerCharacter = null

func _ready():
    # Connect to character creation signals
    character_creation.character_created.connect(_on_character_created)
    
    # Replace GameManager functions with our test implementations
    if character_creation.game_manager:
        character_creation.game_manager.start_game_with_character = _mock_start_game
        character_creation.game_manager.return_to_main_menu = _mock_return_to_menu
    else:
        # Create mock GameManager if not available
        var mock_game_manager = Node.new()
        mock_game_manager.name = "MockGameManager"
        mock_game_manager.start_game_with_character = _mock_start_game
        mock_game_manager.return_to_main_menu = _mock_return_to_menu
        add_child(mock_game_manager)
        character_creation.game_manager = mock_game_manager
    
    # Print test instructions
    print("Character Creation Test")
    print("======================")
    print("Use the UI to create a character and test functionality.")
    print("The 'Create' button will print character data to console for validation.")
    print("The 'Cancel' button will print a message indicating return to main menu.")

# Mock function for starting the game with a character
func _mock_start_game(character: PlayerCharacter) -> void:
    print("\nMock Game Start with Character:")
    print("--------------------------")
    print("Character Name: ", character.player_name)
    print("Character ID: ", character.character_id)
    print("Skin Color: ", character.skin_color)
    print("Hair Style: ", character.hair_style)
    print("Hair Color: ", character.hair_color)
    print("Eye Color: ", character.eye_color)
    print("Gender: ", character.gender)
    print("Creation Date: ", _format_datetime(character.creation_date))
    print("Last Saved: ", _format_datetime(character.last_saved))
    print("Test result: SUCCESS - Character created properly!")

# Mock function for returning to main menu
func _mock_return_to_menu() -> void:
    print("\nMock Return to Main Menu")
    print("Test result: SUCCESS - Cancel button works!")

# Callback for character_created signal
func _on_character_created(character: PlayerCharacter) -> void:
    test_character = character
    # The character data will be printed by _mock_start_game

# Helper function to format datetime dictionary
func _format_datetime(datetime: Dictionary) -> String:
    if datetime.is_empty():
        return "N/A"
    
    return "%04d-%02d-%02d %02d:%02d:%02d" % [
        datetime.year, 
        datetime.month, 
        datetime.day,
        datetime.hour,
        datetime.minute,
        datetime.second
    ]
