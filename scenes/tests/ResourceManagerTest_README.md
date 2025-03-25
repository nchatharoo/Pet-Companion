# ResourceManager Test Scene

This scene is designed to test the ResourceManager singleton component of the Pet Companion game.

## How to Run the Test

1. Open the Godot project
2. Open the `resource_manager_test.tscn` scene from the `scenes/tests` directory
3. Run the scene (F5 or Play button)

## Testing Features

The test scene provides a UI to test the following ResourceManager features:

- **Load Resource (Sync)**: Loads a texture synchronously and displays it
- **Load Resource (Async)**: Loads a texture asynchronously and displays it when ready
- **Unload Resource**: Removes the last loaded resource from the cache
- **Preload Resources**: Preloads multiple resources at once
- **Clear Cache**: Empties the entire resource cache
- **Show Cache Stats**: Displays current cache statistics

## Validation Tests

The test scene validates that:

1. Resources can be loaded both synchronously and asynchronously
2. Caching works properly (subsequent loads of the same resource are faster)
3. Resources can be unloaded from the cache
4. The ResourceManager correctly tracks cache statistics
5. Multiple resources can be preloaded efficiently

## Expected Results

When you run the tests, you should observe:

1. The sample texture should display properly when loaded
2. Second loads of the same resource should be faster than the first (cache hit)
3. Unloading and then reloading a resource should show similar timing to the first load
4. Cache statistics should update to reflect the current state of the cache

## Troubleshooting

If the tests fail:

1. Make sure the ResourceManager is properly registered as an Autoload in project settings
2. Check that the test resources exist in the specified paths
3. Verify that the ResourceManager is correctly initialized in the game

## Modifying the Test

If you need to test with different resources:

1. Open the `resource_manager_test.gd` script
2. Modify the `test_texture_path`, `test_scene_path`, and `test_resources` variables
3. Make sure the paths point to valid resources in the project
4. For best testing, use a mix of different resource types (textures, scenes, audio, etc.)

## Performance Testing

The ResourceManager is designed to optimize