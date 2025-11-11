# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**The Pendulum** is an iOS physics simulation game featuring a rigorous inverted pendulum model with comprehensive analytics, Firebase integration, and educational features. The app combines scientific accuracy with gamification to create an engaging learning tool for physics and control theory.

**Primary Directory**: `src/core/front_end/The Pendulum/`

## Directory Structure

- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/assets/raw` is input data to running the algorithms and GUI's
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/assets/processed` is where results, output data from the algorithms and GUI's should go
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/documentation` and sometimes some subfolders are where documentation of development research and code improvements goes
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/gui` is where the back-end Matlab GUI's will go. There will end up being potentially multiple primary GUI's
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/data` is where useful, critical information on research and development is stored, that might be referred to when adding new features
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/algorithm` is where the main algorithmic code for the Solution goes and that will be eventually ported to C and Python for the front end application engines
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/config` is where configurations for global Python API's like my pysheaf/netlist repository, in `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Golden Core/src/core`. Somewhere in here I'll store the Python geodesics, topological data analysis, and PySheaf/Netlist code will be there that work for all Solutions.
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/testing` is where comprehensive testing will go for running iterative tests as I make improvements
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/debugging` is for adding new code and needing smaller tests to get things working, functions in between complete GUI's being used to transition between complete functionality
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/running` is for running various configurations of the algorithm, potentially with many iterations
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/front_end` is where we'll develop the final Swift application, based off the algorithm
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src/core/prompts` is where I'll store some of the prompts I plan on using to create the Solution
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/src`, all other directories other than `/core/` will be written into by my CI/CD scripts and processes
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/log` is where error log files will go when I'm debugging the GUI, and have finally implement the generation of error logging
- Haven't planned on using `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/analytics`, `Solution/research`, `Solution/experiments`, or `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/releases` yet.
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/releases` is obvious and can take final builds or something one day.
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/analytics` will be after I get all the applications built and running on the front end.
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/research` is what it says, I'm just not ready to use it until the front end is built. Same with `Solution/experiments`.
- `/Users/briandizio/Documents/2023-Now/Golden Enterprise Solutions/Solutions/The Pendulum/integration-tests` will be solution-solution tests. `Solution/metadata` stores data on the solution for the development process.

## Build/Lint/Test Commands

```bash
# Navigate to Xcode project directory
cd "src/core/front_end/The Pendulum"

# Build the project (iOS Simulator)
xcodebuild -project "The Pendulum.xcodeproj" \
  -scheme "The Pendulum" \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' \
  build

# Run the project
xcodebuild -project "The Pendulum.xcodeproj" \
  -scheme "The Pendulum" \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' \
  run

# Run all tests
xcodebuild -project "The Pendulum.xcodeproj" \
  -scheme "The Pendulum" \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' \
  test

# Run a specific test
xcodebuild -project "The Pendulum.xcodeproj" \
  -scheme "The Pendulum" \
  -only-testing:<TestClassName>/<TestMethodName> \
  test
```

## Architecture Overview

### Design Pattern: MVVM + Manager-Based Singletons

The application uses a hybrid architecture:
- **MVVM** for UI components (PendulumViewController + PendulumViewModel)
- **Manager Singletons** for cross-cutting concerns (7 core managers)
- **SpriteKit** for physics visualization
- **CoreData** for local persistence
- **Firebase Firestore** for cloud synchronization

### Core Managers (Singleton Pattern)

| Manager | Purpose | Key Responsibilities |
|---------|---------|----------------------|
| `AnalyticsManager` | Metrics & tracking | Session tracking, 100+ metrics calculation, CoreData storage |
| `CoreDataManager` | Local persistence | Entity management, fetch/save operations, migration |
| `FirebaseManager` | Cloud sync | Authentication, Firestore sync, merge conflict resolution |
| `LevelManager` | Game progression | Level definitions, difficulty scaling, completion tracking |
| `PerturbationManager` | External forces | Level-specific perturbations, randomization profiles |
| `SettingsManager` | User preferences | Load/save settings, real-time application to game state |
| `BackgroundManager` | Visual themes | Background image management, theme categories |

### Key Components

**Physics Engine** (`pendulumModel.swift`, `NumericalODESolvers.swift`):
- Inverted pendulum differential equations: `θ'' = -ka·sin(θ) + ks·θ - kb·ω + F(t)`
- RK4 ODE solver (primary), with Euler and Improved Euler fallbacks
- Configurable parameters: mass, length, gravity, damping, spring constant, moment of inertia

**Main View Controller** (`PendulumViewController.swift` ~3500 lines):
- Tab-based navigation: Simulation, Dashboard, Modes, Integration, Parameters, Settings
- SpriteKit scene management for pendulum visualization
- Game HUD: score, time, level, balance progress
- AI assistance visualization (tutorial, competition modes)

**Analytics Dashboard** (`SimpleDashboard.swift`):
- **CRITICAL**: This is the ONLY active dashboard (archived dashboards exist but are NOT used)
- Displays 6 metric groups: Basic, Advanced, Scientific, Educational, Topology, Performance
- Real-time updates via timer (0.5s interval)
- Time range filtering: Session, Daily, Weekly, Monthly, Yearly

**Data Flow**:
```
User Interaction → PendulumViewController
                ↓
         PendulumViewModel (MVVM)
                ↓
    Physics Engine (InvertedPendulumModel)
                ↓
    SpriteKit Scene (PendulumScene)
                ↓
    AnalyticsManager → CoreData + Firebase
                ↓
         SimpleDashboard
```

## Critical Files

### Must-Read for Any Work (read in chunks of 7500 tokens):

1. **PendulumViewController.swift** (~3500 lines) - Main view controller, tab management, HUD, controls
2. **pendulumModel.swift** - Physics engine, differential equations, ODE solvers
3. **SimpleDashboard.swift** - PRIMARY analytics dashboard (the only one in use)
4. **AnalyticsManager.swift** (~1500 lines) - Session tracking, metric calculation
5. **AnalyticsManagerExtensions.swift** - Metric calculation implementations
6. **PendulumViewModel.swift** - MVVM view model, game state management

### Essential Supporting Files:

7. **CoreDataManager.swift** - Local data persistence
8. **FirebaseManager.swift** - Cloud sync, authentication
9. **LevelManager.swift** - Game progression, level definitions
10. **PerturbationManager.swift** - External force system
11. **SettingsManager.swift** - User preferences
12. **MetricsCalculator.swift** - Scientific metrics (phase space, Lyapunov, etc.)

## Important: Dashboard Architecture

⚠️ **CRITICAL CONSTRAINT**: This project uses `SimpleDashboard.swift`, NOT the Enhanced Dashboard!

### Dashboard Rules:
- ✅ **ALWAYS use SimpleDashboard** - This is the only dashboard the user sees
- ✅ **Test with SimpleDashboard** - Switch to "Scientific" tab to verify metrics
- ❌ **NEVER reference** `Archive_Unused_Dashboards/AnalyticsDashboardView.swift`
- ❌ **NEVER reference** `Archive_Unused_Dashboards/EnhancedAnalyticsDashboard.swift`
- ❌ **Do NOT confuse** the implementations - only SimpleDashboard is active

### Analytics Data Flow:
```
AnalyticsManager.trackInteraction()
        ↓
AnalyticsManagerExtensions.calculateMetrics()
        ↓
MetricsCalculator.calculate*() methods
        ↓
SimpleDashboard displays results
```

## Development Patterns

### When Adding New Features:

1. **Physics changes**: Modify `InvertedPendulumModel` or `NumericalODESolvers.swift`
2. **New metrics**: Add to `AnalyticsManagerExtensions.swift` + `MetricsCalculator.swift`
3. **UI changes**: Update `PendulumViewController.swift` and corresponding tab view
4. **Game mechanics**: Modify `LevelManager.swift` or `PerturbationManager.swift`
5. **Persistence**: Add CoreData entities in `PendulumScoreData.xcdatamodeld`

### When Debugging:

1. **Physics issues**: Check `pendulumModel.swift` differential equations and ODE solver
2. **Metrics showing 0.00**: Verify `AnalyticsManager.isTracking` is true and session is active
3. **Dashboard not updating**: Check `SimpleDashboard` timer (0.5s interval) and `loadMetrics()`
4. **Firebase sync issues**: Check `FirebaseManager` merge strategy (keep highest score)
5. **Crashes on invalid data**: Validate for NaN/Infinite in `AnalyticsManager.trackInteraction()`

### Testing Strategy:

- **Unit tests**: `The PendulumTests/` (8 test files covering model, managers, analytics)
- **UI tests**: `The PendulumUITests/` (basic flow testing)
- **Developer Tools**: Settings tab includes "Generate Test Data", "Fix Zero Metrics" buttons

## Code Style Guidelines

- **Naming**: camelCase for variables/functions, PascalCase for types/classes
- **Imports**: Group by framework (SpriteKit, Foundation, UIKit, Firebase)
- **Types**: Explicit types for properties, use `guard` for optional unwrapping
- **Documentation**: Use `///` for public APIs with parameter descriptions
- **Organization**: Properties → Initializers → Lifecycle → Public Methods → Private Methods
- **Error Handling**: Try/catch with meaningful error messages, log to console
- **Access Control**: Always specify (private, internal, public)
- **Indentation**: 2 spaces, blank line between methods

## Large File Handling

When reading files that exceed token limits:

1. **ALWAYS read files completely** using multiple Read operations with chunks of 7500 tokens
2. Start with `offset=0`, increment by chunk size until EOF
3. **Never sample portions** - full understanding prevents bugs

Example:
```python
# First chunk
Read(file_path="PendulumViewController.swift", offset=0, limit=7500)
# Second chunk
Read(file_path="PendulumViewController.swift", offset=7500, limit=7500)
# Continue until complete
```

## Firebase Integration

### Authentication:
- Sign In with Apple (production)
- Email/Password (development)
- Anonymous auth (fallback)
- Auth state persisted across launches

### Firestore Structure:
```
users/{userId}/
  ├── profile (email, name, createdAt)
  ├── sessions/{sessionId} (score, duration, timestamp)
  ├── analytics/{metricId} (type, value, timestamp)
  └── achievements/{achievementId} (unlocked, timestamp)
```

### Merge Strategy:
- **Conflict resolution**: Keep highest score on sync
- **Offline support**: CoreData as source of truth
- **Sync trigger**: App launch, background/foreground transition

## Physics Implementation

### Inverted Pendulum Equations:

```
θ'' = -ka·sin(θ) + ks·θ - kb·ω + F(t)

where:
  ka = (m·l·g) / (m·l² + I)    [gravity coefficient]
  ks = k / (m·l² + I)           [spring coefficient]
  kb = b / (m·l² + I)           [damping coefficient]
  F(t) = A·sin(2π·f·t)         [external drive]
```

### Numerical Methods:
- **Primary**: Runge-Kutta 4th order (RK4) - most accurate
- **Fallback**: Improved Euler (RK2)
- **Debug**: Euler (1st order) - fastest, least accurate

### State Variables:
- `θ` (theta): Angle from vertical (radians)
- `ω` (omega): Angular velocity (rad/s)
- `t`: Simulation time (seconds)

## Analytics System

### Metric Categories (100+ metrics total):

1. **Basic**: Stability, efficiency, session time, push count, level
2. **Advanced**: Overcorrection, response delay, angular deviation, force distribution
3. **Scientific**: Phase space coverage, energy management, Lyapunov exponent
4. **Educational**: Learning curve, skill retention, adaptation rate
5. **Topology**: Winding number, periodic orbits, basin stability, Betti numbers
6. **Performance**: CPU usage, frame rate, memory efficiency

### Real-Time Tracking:
- Session start: `AnalyticsManager.startTracking(for: sessionId)`
- State updates: `trackPendulumState(angle:angleVelocity:)` called per frame
- Interactions: `trackInteraction(eventType:angle:angleVelocity:magnitude:direction:)`
- Session end: `stopTracking()` calculates final metrics

## Current Project Status

### Completed Features:
- ✅ Full physics simulation with rigorous inverted pendulum model
- ✅ 100+ analytics metrics across 6 categories
- ✅ Firebase authentication and cloud sync
- ✅ CoreData local persistence with migration support
- ✅ SimpleDashboard with real-time updates
- ✅ 10+ game levels with progressive difficulty
- ✅ AI assistance modes (tutorial, competition)
- ✅ Comprehensive testing infrastructure
- ✅ Background themes (AI, Acadia, Fluid, Topology, Joshua Tree, TSP, Sachuest, Parchment, Outer Space)
- ✅ Sound effects and audio management

### Known Issues:
- Console may show NaN/Infinite validation warnings (expected, prevents crashes)
- Some scientific metrics require active gameplay to populate (not bugs)

### Next Steps:
- Precompute and upload additional Modes and Settings data (MATLAB analysis)
- Further UI/UX polish for enhanced playability

## AI & Topological Features

The app includes advanced mathematical features for research and education:

- **Phase Space Analysis**: Visualize pendulum dynamics in θ-ω space
- **Lyapunov Exponent**: Measure system chaos and predictability
- **Persistent Homology**: Topological data analysis of trajectory patterns
- **Winding Number**: Count full rotations around equilibrium
- **Basin Stability**: Quantify size of stable attraction regions

These features make the app suitable for:
- Control theory education
- Nonlinear dynamics research
- Chaos theory demonstrations
- Human-machine interaction studies

## Important Reminders

- **SimpleDashboard** is the ONLY active dashboard - do not reference archived dashboards
- **Always validate for NaN/Infinite** before storing numeric values in analytics
- **CoreData is source of truth** for local data, Firebase is sync layer
- **Read large files completely** using chunked reads (7500 token chunks)
- **Test with Developer Tools** in Settings tab for quick metric validation
