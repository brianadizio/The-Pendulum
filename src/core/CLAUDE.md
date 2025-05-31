# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Lint/Test Commands
- Build project: `xcodebuild -workspace "The Pendulum/The Maze.xcworkspace" -scheme "The Pendulum" build`
- Run project: `xcodebuild -workspace "The Pendulum/The Maze.xcworkspace" -scheme "The Pendulum" run`
- Run a single test: `xcodebuild -workspace "The Pendulum/The Maze.xcworkspace" -scheme "The Pendulum" -only-testing:<TestClassName>/<TestMethodName> test`
- Install dependencies: `pod install --project-directory="The Pendulum"`

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
- AnalyticsDashboardViewNative.swift
- AnalyticsDashboardView.swift

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

## Milestone Notes
- Great job, Claude, together, the application is in a good state. It has full scientific functionality, it's playable, it has graphics, it has sounds, and it's becoming alive.

## Progress Notes
- Good reseting, adjusting to the problem with the tangled, complicated enhanced dashboard, and refining the solution to a more clear, crystal simplified implementation that includes all data from progressive coding

## Recent Interactions
- This is really efficient, smart coding.  This is exactly what the application needed, will help me debug it, and Claude implemented it very swiftly and accurately.