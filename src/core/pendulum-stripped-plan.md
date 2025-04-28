# The Pendulum - Stripped-Down Project Plan

## Core Files to Keep

### Simulation Core
1. `NumericalODESolvers.swift` - Essential ODE solvers including Runge-Kutta implementation
2. `pendulum-model.swift` - Core pendulum model
3. `pendulum-physics.swift` - Physics calculations for the pendulum
4. `pendulum-node2.swift` - Visual representation of pendulum in SpriteKit
5. `pendulum-simulation2.swift` - Simulation implementation
6. `pendulum-test.swift` - Testing framework for pendulum simulation

### Visualization
1. `game-scene2.swift` - Main SpriteKit scene for pendulum visualization
2. `pendulum-button-controls.swift` - Control UI elements for interacting with the pendulum

### Data
1. `InputPendulumSim.csv` - Input parameters for simulation
2. `OutputPendulumSim.csv` - Reference data for validation

## Components to Remove
1. All maze-related files (The Maze CodeGen directory)
2. All game controllers and scene files for mazes
3. CoreData and metrics tracking related code
4. Multiple UI views unrelated to the pendulum

## New Project Structure

```
ThePendulum/
├── Models/
│   ├── PendulumModel.swift
│   ├── PendulumPhysics.swift
│   └── PendulumSimulation.swift
├── Views/
│   ├── PendulumScene.swift
│   └── PendulumControls.swift
├── Utilities/
│   └── NumericalODESolvers.swift
├── Resources/
│   ├── InputPendulumSim.csv
│   └── OutputPendulumSim.csv
└── Application/
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    └── Main.storyboard
```

## Implementation Plan

1. Create a new Xcode project with a simple SpriteKit template
2. Copy the core files listed above into the appropriate directories
3. Implement a simplified AppDelegate and SceneDelegate
4. Create a minimal UI with just:
   - The pendulum visualization
   - Left/right control buttons
   - Reset button
   - Parameter adjustment controls (optional)
5. Ensure all file dependencies are correctly updated
6. Remove any references to CoreData or other unneeded frameworks
7. Test the pendulum simulation and visualization
8. Clean up any remaining references to the old project

## Technical Requirements

- Swift 5.0+
- iOS 14.0+
- Required frameworks:
  - SpriteKit
  - SwiftUI (optional, for parameter controls)
  - Foundation