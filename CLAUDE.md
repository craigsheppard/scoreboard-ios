# Scoreboard App Development Guide

## Build & Run Commands
- Build and run: Open Xcode project and use Cmd+R
- Clean build: Cmd+Shift+K in Xcode
- Build only: Cmd+B in Xcode
- Running tests: Cmd+U in Xcode
- Run specific test: Select test method and press Ctrl+Alt+Cmd+U

## Code Style Guidelines
- **Naming**: Use camelCase for variables/functions, PascalCase for types/protocols
- **Views**: Suffix with "View" (e.g., ScoreboardView)
- **Components**: Suffix with "Component" for reusable views
- **Models**: Use plain structs that conform to Codable when persistence needed
- **Error Handling**: Use enums with LocalizedError, Result type for async operations
- **State Management**: Prefer @State, @Binding, @EnvironmentObject for view state
- **Formatting**: 4-space indentation, no trailing whitespace
- **Architecture**: Follow MVVM pattern with SwiftUI views
- **Extensions**: Prefer extensions for adding functionality to existing types
- **Color Handling**: Use CodableColor for persistence of SwiftUI Color
- **Comments**: Document public APIs and complex logic