# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Scoreboard is an iOS app for tracking scores in two-team games (hockey, basketball, soccer, table tennis). It features customizable team colors, tap/swipe gestures for scoring, and iCloud sync via CloudKit.

## Build & Run Commands
- **Open project**: `open "Scoreboard ∞.xcodeproj"`
- **Build and run**: Cmd+R in Xcode
- **Clean build**: Cmd+Shift+K in Xcode
- **Build only**: Cmd+B in Xcode
- **Run all tests**: Cmd+U in Xcode
- **Run specific test**: Select test method and press Ctrl+Alt+Cmd+U

## Architecture

### Orientation-Based Navigation
The app switches views based on device orientation (ContentView.swift:8-16):
- **Portrait**: ConfigureView (team setup, saved teams, game type selection)
- **Landscape**: ScoreboardView (active scoreboard display)

### State Management
- **AppConfiguration**: Root `ObservableObject` managing global state, injected via `@EnvironmentObject`
  - Manages `homeTeam` and `awayTeam` (TeamConfiguration instances)
  - Manages `savedTeams` array and `currentGameType`
  - Auto-saves configuration changes to UserDefaults
  - Coordinates iCloud sync via CloudKitManager

- **TeamConfiguration**: `ObservableObject` representing a team's properties
  - Properties: teamName, primaryColor, secondaryColor, fontColor, score
  - Tracks `savedTeamId` to link with SavedTeam records
  - Tracks `lastSavedState` for detecting unsaved changes

### CloudKit Integration
- **CloudKitManager**: Singleton managing iCloud persistence
  - Stores teams in private CloudKit database as single "userTeams" record
  - Teams encoded as JSON blob in CKRecord "teamsData" field
  - Uses CKQuerySubscription for remote change notifications
  - Merge strategy: cloud changes merged with local teams, cloud version wins on conflicts

- **Remote Notifications**: AppDelegate handles CloudKit push notifications
  - Triggers `teamsDidChangePublisher` (Combine PassthroughSubject)
  - AppConfiguration subscribes to reload teams when remote changes occur

### Data Models
- **SavedTeam**: Identifiable, Codable struct for persisted teams
  - UUID-based identity for deduplication across devices
  - Includes gameType to filter teams by sport
  - Converts to TeamConfiguration for active use

- **CodableColor**: Wrapper for SwiftUI Color with Codable conformance
  - Stores RGBA components as Doubles
  - Required because SwiftUI Color is not Codable

- **GameType**: Enum defining supported sports (hockey, basketball, soccer, tableTennis)

### Persistence Strategy
1. **UserDefaults**: Primary local storage (AppConfiguration.swift:135-158)
   - Current game configuration saved automatically on any team property change
   - Saved teams array cached locally as fallback

2. **CloudKit**: Secondary cloud storage (AppConfiguration.swift:229-238)
   - Teams synced when iCloudAvailable is true
   - Graceful degradation: failures fall back to UserDefaults
   - Merge strategy preserves local-only teams during sync

## Code Style Guidelines
- **Naming**: camelCase for variables/functions, PascalCase for types/protocols
- **Views**: Suffix with "View" (e.g., ScoreboardView)
- **Components**: Suffix with "Component" for reusable views
- **Models**: Plain structs conforming to Codable for persistence
- **Error Handling**: Enums with LocalizedError, Result type for async operations
- **State Management**: @State, @Binding, @EnvironmentObject for view state
- **Formatting**: 4-space indentation, no trailing whitespace
- **Architecture**: MVVM pattern with SwiftUI views
- **Extensions**: Prefer extensions for adding functionality to existing types
- **Color Handling**: Use CodableColor for persistence of SwiftUI Color
- **Comments**: Document public APIs and complex logic

## Git Workflow
- **NEVER push directly to main branch** - Always use feature branches and pull requests
- **Branch naming**: Use descriptive names like `feature/add-scoring`, `bugfix/haptic-timing`
- **Commit messages**: Use clear, descriptive messages explaining what changed and why
- **Pull requests**: Create PRs for all changes, even small ones, to maintain code review process
- **Feature branches**: Create from main, merge back via PR after review

## Key Patterns
- **Reactive auto-save**: Combine publishers trigger saves when team properties change (AppConfiguration.swift:125-133)
- **iCloud availability check**: App checks CloudKit availability at launch and enables sync conditionally
- **Team identity tracking**: TeamConfiguration.savedTeamId links active teams to SavedTeam records for update detection
- **Saved state comparison**: TeamSavedState snapshot detects unsaved changes in UI
