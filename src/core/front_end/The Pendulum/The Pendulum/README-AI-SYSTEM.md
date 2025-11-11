# AI System for The Pendulum

## Overview

The AI system provides two main features:
1. **AI Test Data Generation** - Automatically generates gameplay data to populate the analytics dashboard
2. **AI Opponent** - An AI player that can balance the pendulum with configurable skill levels

## Components

### 1. PendulumAIPlayer.swift
The core AI player implementation that can balance the pendulum.

**Features:**
- 5 skill levels: Beginner, Intermediate, Advanced, Expert, Perfect
- PD (Proportional-Derivative) control algorithm for pendulum balancing
- Human error simulation including:
  - Wrong direction errors
  - Magnitude errors  
  - Timing errors
  - Missed actions
- Adaptive control strategies based on pendulum state
- Learning system that adjusts strategy based on performance

**Usage:**
```swift
// Start AI player
PendulumAIManager.shared.startAIPlayer(skillLevel: .intermediate, viewModel: viewModel)

// Stop AI player
PendulumAIManager.shared.stopAIPlayer()
```

### 2. AITestingSystem.swift
System for running automated tests to generate dashboard data.

**Test Configurations:**
- **Quick Test** - 5 minutes, single session, basic data
- **Comprehensive Test** - Multiple sessions with different perturbation modes
- **Long Term Test** - Extended sessions for historical data generation

**Usage:**
```swift
// Generate quick dashboard data
AITestingSystem.generateQuickDashboardData()

// Run comprehensive test
AITestingSystem.generateComprehensiveTestData()
```

### 3. UI Integration
The AI Test button has been added to the simulation view control panel.

**Button Location:**
- Third row in the control panel (below Start/Stop and Push buttons)
- Blue color to distinguish from other controls
- Centered in its row

**Button Actions:**
1. **Quick Test (5 min)** - Generates basic dashboard data quickly
2. **Comprehensive Test** - Runs multiple AI sessions with varying parameters
3. **Play vs AI** - Activates an AI opponent that plays the game

## How It Works

### AI Control Algorithm
The AI uses a PD (Proportional-Derivative) controller to balance the pendulum:

```
control_force = -kp * angle - kd * angle_velocity
```

Where:
- `kp` = proportional gain (how strongly to correct position errors)
- `kd` = derivative gain (how strongly to dampen velocity)

### Skill Level Effects

| Skill Level | Reaction Time | Error Rate | Force Accuracy | Anticipation |
|-------------|---------------|------------|----------------|--------------|
| Beginner    | 0.4-0.8s      | 30%        | 60%            | 20%          |
| Intermediate| 0.3-0.5s      | 20%        | 75%            | 40%          |
| Advanced    | 0.2-0.4s      | 10%        | 85%            | 60%          |
| Expert      | 0.1-0.3s      | 5%         | 95%            | 80%          |
| Perfect     | 0.05-0.1s     | 0%         | 100%           | 100%         |

### Human Error Simulation
To make the AI more realistic, it simulates human errors:

1. **Wrong Direction** - Pushes the wrong way (overcorrection)
2. **Magnitude Error** - Applies too much or too little force
3. **Timing Error** - Delays or rushes the action
4. **Missed Action** - Fails to act when needed

### Dashboard Data Generation
The AI testing system generates realistic gameplay data by:

1. Running AI players with different skill levels
2. Testing various perturbation modes (Progressive, Random Impulses, etc.)
3. Simulating parameter variations across sessions
4. Creating time-series data for all metrics
5. Saving results to Core Data for dashboard display

## Usage Instructions

### To Generate Dashboard Data:
1. Open the app and go to the Simulation tab
2. Tap the "AI Test" button
3. Select "Quick Test" for fast results or "Comprehensive Test" for more data
4. Wait for the test to complete
5. Go to the Dashboard tab to see the generated data

### To Play Against AI:
1. Open the app and go to the Simulation tab
2. Tap the "AI Test" button
3. Select "Play vs AI"
4. Watch the AI balance the pendulum
5. Tap "Stop AI" when done

## Technical Notes

- The AI runs at 20Hz (50ms update interval)
- Force calculations are capped at ±3.0 to match game physics
- The AI tracks phase space trajectory for optimal control
- All AI actions are logged in the analytics system
- Test data is persisted in Core Data

## Future Enhancements

1. **Competitive Mode** - Player vs AI with scoring
2. **AI Difficulty Adaptation** - AI adjusts to match player skill
3. **Training Mode** - AI demonstrates optimal techniques
4. **Multiplayer AI** - Multiple AIs working together
5. **Custom AI Profiles** - User-defined AI behaviors