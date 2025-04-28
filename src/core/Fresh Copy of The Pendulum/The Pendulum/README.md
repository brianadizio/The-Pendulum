# The Pendulum Simulation

A physics-based inverted pendulum simulation using SpriteKit with customizable parameters through CSV files.

## Overview

This app simulates a pendulum system with:
- Configurable physical parameters (mass, length, gravity, damping)
- Numerical ODE solvers (Runge-Kutta 4th order)
- Interactive controls to apply forces
- Visualization of the pendulum's motion

## Features

- Import parameters from CSV files
- Compare simulation with reference data
- Interactive push controls
- Visual trail showing the pendulum's path

## CSV Input Format

The app reads parameters from `InputPendulumSim.csv` with the following format:

```
70,       # Mass (row 1)
0,        # (row 2 - unused)
1,        # Length (row 3)
9.801,    # Gravity (row 4)
0,        # (row 5 - unused)
0,        # (row 6 - unused)
0.005,    # Time step (row 7)
pi/2,     # Initial angle (row 8)
0.1,      # Damping coefficient (row 9)
```

Special values like `pi/2` are automatically parsed. The app also supports loading a reference dataset from `OutputPendulumSim.csv` for comparison.

## Usage

1. Launch the app
2. Press "Start" to begin the simulation
3. Use the "Push →" and "← Push" buttons to apply forces to the pendulum
4. Press "Stop" to pause the simulation

## Implementation Details

The app uses:
- SpriteKit for visualization
- Custom CSV parser (no external dependencies)
- Runge-Kutta 4th order solver for numerical integration
- MVVM architecture

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

## License

Copyright © 2025 Golden Enterprises Solutions