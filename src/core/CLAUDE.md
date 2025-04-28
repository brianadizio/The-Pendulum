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