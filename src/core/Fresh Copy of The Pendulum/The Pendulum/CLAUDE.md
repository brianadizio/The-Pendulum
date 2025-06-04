# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Lint/Test Commands
- Build project: `xcodebuild -project "The Pendulum.xcodeproj" -scheme "The Pendulum" -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' build`
- Run project: `xcodebuild -project "The Pendulum.xcodeproj" -scheme "The Pendulum" -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' run`
- Run a single test: `xcodebuild -project "The Pendulum.xcodeproj" -scheme "The Pendulum" -only-testing:<TestClassName>/<TestMethodName> test`

## IMPORTANT: Dashboard Implementation 

⚠️ **CRITICAL: This project uses SimpleDashboard, NOT the Enhanced Dashboard!**

### Current Dashboard Architecture:
- **PRIMARY DASHBOARD**: `SimpleDashboard.swift` - This is the ONLY dashboard currently in use
- **ARCHIVED DASHBOARDS**: `Archive_Unused_Dashboards/` folder contains:
  - `AnalyticsDashboardView.swift` (OLD - not used)
  - `EnhancedAnalyticsDashboard.swift` (OLD - not used)

### When Working with Analytics/Metrics:
- ✅ **ALWAYS use SimpleDashboard** - This is what the user sees
- ✅ **Test with SimpleDashboard** - Switch to "Scientific" tab to see metrics
- ❌ **NEVER reference or modify** the archived Enhanced Dashboard files
- ❌ **Do NOT confuse** the dashboard implementations

### Scientific Metrics Fix Applied:
- Scientific metrics (Phase Space Coverage, Energy Management, Lyapunov Exponent) now work correctly
- Use "Generate Test Dashboard Data" or "Fix Zero Metrics" in Developer Tools
- Data flows through: `AnalyticsManagerExtensions` → `MetricsCalculator` → `SimpleDashboard`

## Code Style Guidelines
- **Naming**: Use camelCase for variables/functions, PascalCase for types/classes
- **Imports**: Group imports by framework (SpriteKit, Foundation, etc.)
- **Types**: Use explicit types for class properties, optional unwrapping with if/guard
- **Documentation**: Use /// for documentation comments with parameter explanations
- **Code Organization**: Place properties at top of class, followed by initializers, then methods
- **Error Handling**: Use try/catch for errors, provide meaningful error messages
- **Access Control**: Specify access modifiers (private, internal, public) for all properties and methods
- **Whitespace**: Use 2-space indentation, blank line between methods

## Key Files to Read
When analyzing this codebase, be sure to read these critical files using offset 0 and chunks of 7500 tokens:
- PendulumViewController.swift
- pendulumModel.swift
- SimpleDashboard.swift (PRIMARY dashboard - NOT the archived ones)
- AnalyticsManagerExtensions.swift
- MetricsCalculator.swift

## Large File Handling
When encountering a file that exceeds token limits:
- ALWAYS read the file in its entirety by using multiple Read operations with chunks of 7500 tokens
- Start with offset=0 and continue incrementing the offset by the chunk size until the entire file is read
- Lean towards reading files completely rather than just sampling portions
- This ensures full understanding of the code structure and prevents missing critical implementation details
- Example for a large file:
  - First chunk: Read file_path="/path/to/file" offset=0 limit=7500
  - Second chunk: Read file_path="/path/to/file" offset=7500 limit=7500
  - Continue until reaching the end of the file

## Project Focus
- This core functionality of The Pendulum, the scientific modeling, and base controls and application are important to making it a rigorous research tool and for making it a living topology solution.
- Remember this state of the application, as it's almost completely ready with UI, the physics is right, and only some Modes and Settings need to be precomputed, analyzed in Matlab and uploaded.
- Great UI, correlates with playability of the game.
- **SimpleDashboard provides the analytics interface** - focus development efforts here

## Debug Output Status
- ✅ **Console flooding RESOLVED** - All DEBUG print statements removed
- ✅ **Scientific metrics WORKING** - Fixed for SimpleDashboard specifically  
- ✅ **Data generation FUNCTIONAL** - Use Developer Tools to populate metrics

## Milestone Notes
- Great job, Claude, together, the application is in a good state. It has full scientific functionality, it's playable, it has graphics, it has sounds, and it's becoming alive.
- **SimpleDashboard integration complete** - Scientific metrics now display real values instead of 0.00

## Progress Notes
- Good reseting, adjusting to the problem with the tangled, complicated enhanced dashboard, and refining the solution to a more clear, crystal simplified implementation that includes all data from progressive coding
- **Dashboard architecture clarified** - Only SimpleDashboard is used, archived enhanced dashboards to prevent confusion

## Recent Interactions
- This is really efficient, smart coding. This is exactly what the application needed, will help me debug it, and Claude implemented it very swiftly and accurately.
- **SimpleDashboard scientific metrics fix successfully implemented** - Phase Space Coverage, Energy Management, and Lyapunov Exponent now show meaningful values

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
**ALWAYS work with SimpleDashboard.swift - it's the ONLY dashboard in active use.**