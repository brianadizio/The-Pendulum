# The Pendulum - Migration Instructions

This document provides step-by-step instructions for creating a new, clean Xcode project for The Pendulum app using the stripped-down files.

## Step 1: Create a New Xcode Project

1. Open Xcode and select "Create a new Xcode project"
2. Choose "Game" as the template
3. Set the following options:
   - Product Name: ThePendulum
   - Organization Identifier: com.yourdomain
   - Game Technology: SpriteKit
   - Language: Swift
   - User Interface: Storyboard
   - Uncheck any checkboxes for tests
4. Choose a location to save the project

## Step 2: Replace Template Files with Stripped Files

Replace the following files in your new project with the ones from the `stripped-files` directory:

1. Replace `AppDelegate.swift`
2. Replace `SceneDelegate.swift`
3. Replace `GameViewController.swift`

## Step 3: Add Core Files

Add the following files to your project:
1. `NumericalODESolvers.swift`
2. `PendulumModel.swift`
3. `PendulumNode.swift`
4. `PendulumScene.swift`

## Step 4: Modify Project Settings (if needed)

1. Update the iOS deployment target in the project settings to iOS 13.0 or higher
2. Ensure SpriteKit is included in the linked frameworks

## Step 5: Clean and Build

1. Select Product > Clean Build Folder
2. Build and run the project on a simulator or device

## Step 6: Verify Operation

When running, you should see:
1. A pendulum suspended from the top center of the screen
2. Control buttons at the bottom (left, right, and reset)
3. A debug label at the top showing pendulum state

The pendulum should start with a small initial angle and respond to control inputs.

## Step 7: Add Parameters UI (Optional Enhancement)

For a more interactive experience, you may want to add a user interface for adjusting pendulum parameters such as:
- Mass
- Length
- Damping
- Spring constant
- Drive frequency/amplitude

This could be implemented using:
1. UIKit (sliders and labels)
2. SwiftUI (if targeting iOS 13+)
3. SpriteKit UI elements

## Troubleshooting

If you encounter issues:

1. **Compilation errors**: Ensure all files have been added to the target and their relationships are maintained
2. **Runtime errors**: Check the console for detailed error messages
3. **Blank screen**: Verify the PendulumScene is being properly instantiated and presented
4. **Performance issues**: Adjust the simulation time step or toggle debug visualizations

## Additional Resources

- The `README.md` file provides an overview of the physics model
- Apple's [SpriteKit Programming Guide](https://developer.apple.com/spritekit/)
- Apple's [Game Development documentation](https://developer.apple.com/game-center/)