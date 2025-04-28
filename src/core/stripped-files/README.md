# The Pendulum - iOS App

A physics simulation of an inverted pendulum system.

## Overview

This app provides a visual simulation of an inverted pendulum with the following features:
- Accurate physics simulation using Runge-Kutta 4th order numerical integration
- Interactive controls to apply forces to the pendulum
- Adjustable physics parameters

## Files and Structure

### Core Simulation
- `NumericalODESolvers.swift` - Implementation of ODE solvers (Euler, Improved Euler, Runge-Kutta)
- `PendulumModel.swift` - Main physics model for the pendulum

### Visualization
- `PendulumNode.swift` - SpriteKit node for rendering the pendulum
- `PendulumScene.swift` - SpriteKit scene containing the pendulum and controls

### Application Files
- `AppDelegate.swift` & `SceneDelegate.swift` - Standard iOS app infrastructure
- `GameViewController.swift` - Main view controller that hosts the SpriteKit scene

## Setup Instructions

1. Create a new Xcode project using the "Game" template with SpriteKit
2. Replace the template files with the ones provided in this directory
3. Ensure the Info.plist has the necessary entries for app configuration
4. Build and run the application

## Physics Model

The pendulum simulation is based on the following differential equation:

```
θ'' = (m*l*g)/(m*l^2 + I) * sin(θ) - k/(m*l^2 + I) * θ - b/(m*l^2 + I) * θ' + F
```

Where:
- θ is the angle
- m is the mass
- l is the length
- g is gravity
- I is the moment of inertia
- k is the spring constant
- b is the damping coefficient
- F is the applied force

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+