# Pet Companion - Architecture Documentation

## Overview
This document describes the architecture of the Pet Companion game, implementation details, and design decisions.

## Project Configuration

### Basic Settings
- **Name:** PetCompanion
- **Version:** 0.1.0
- **Main Scene:** res://scenes/main/main.tscn
- **User Data Directory:** PetCompanion (custom directory for save data)

### Display Settings
- **Resolution:** 1280x720 viewport
- **Stretch Mode:** canvas_items with keep_height aspect
- **Mobile Orientation:** sensor_landscape
- **iOS Specific:** hide home indicator and status bar

### Input Configuration
- Touch emulation from mouse enabled
- Mouse emulation from touch disabled (for better mobile experience)

### Rendering Configuration
- **Rendering Method:** mobile (optimized for cross-platform)
- **Anti-Aliasing:** MSAA 2D and 3D level 1
- **Driver:** GLES2 for broader compatibility
- **Texture Compression:**
  - ETC for Android
  - PVRTC for iOS
- **Shadow Settings:** Reduced for mobile
- **Default Environment:** Custom environment resource with optimized settings

### Debug Settings
- FPS forced to 60 in debug mode
- FPS counter enabled in debug mode

### Physics Settings
- 30 physics ticks per second (optimized for mobile)
- Maximum of 4 physics steps per frame

### Export Configurations
- Windows Desktop (x86_64)
- macOS (universal)
- Android (arm64-v8a, armeabi-v7a)
- iOS (arm64)

## Directory Structure
- `/assets`: Contains all game assets (models, textures, animations, sounds, UI)
- `/scripts`: Contains all game scripts, organized by system
  - `/core`: Core game systems and managers
  - `/entities`: Character and object scripts
    - `/animals`: Animal behaviors and state machines
    - `/player`: Player character functionality
  - `/ui`: User interface components
  - `/data`: Data management and persistence
- `/scenes`: Contains all game scenes
  - `/main`: Main game scenes (title, game world)
  - `/character_creation`: Character creation UI and logic
  - `/house`: House environments and components
- `/resources`: Resource files and configurations
  - `default_env.tres`: Default environment settings for consistent lighting and effects

## Core Systems

### GameManager (scripts/core/GameManager.gd)
Singleton responsible for overall game state management, including:
- Game state transitions (menu, gameplay, paused)
- Scene loading and management
- High-level game flow control

### ResourceManager (scripts/core/ResourceManager.gd)
Handles dynamic resource loading/unloading with features:
- Asynchronous resource loading
- Resource caching for performance
- Memory management for mobile optimization

### SettingsManager (scripts/core/SettingsManager.gd)
Manages user preferences and game settings:
- Audio settings
- Graphics quality options
- Input configuration
- Platform-specific optimizations

## Entity System

### Animal Base Class (scripts/entities/animals/Animal.gd)
Base class for all animal types with:
- Common animal attributes (energy, hunger, etc.)
- Need simulation system
- Interaction handling

### Animal State Machine (scripts/entities/animals/AnimalStateMachine.gd)
Implements behavior AI using state pattern:
- State transitions based on animal needs
- Decoupled state logic
- Extensible for new behaviors

### Player Character (scripts/entities/player/PlayerCharacter.gd)
Player character implementation with:
- Character customization properties
- Movement and interaction systems
- Serialization for save/load functionality
