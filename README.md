Scoreboard

Scoreboard is an iOS app to allow you to easily keep track of any game where two teams play.

It allows for customizable team colours, and you can set the score by tapping or swipe gestures. Haptic and visual feedback allow you to be confident that the score was set.

## Features

- **Multiple Game Types**: Hockey, Basketball, Soccer, Table Tennis
- **Basketball Swipe Scoring**: Interactive 2-point and 3-point targets with multi-haptic feedback
- **Team Management**: Save and load teams with custom colors
- **iCloud Sync**: Team configurations sync across devices via CloudKit
- **Swap Sides**: Quick button to swap team positions

## Release Process

This project uses automated versioning via Xcode Cloud. The version number is automatically extracted from git tags.

### Creating a Release

1. **Merge your PR to main**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create and push a version tag**
   ```bash
   git tag v1.2.0
   git push origin v1.2.0
   ```

3. **Xcode Cloud automatically builds the tagged version**
   - Version set to `1.2.0` (from tag)
   - Build number set to Xcode Cloud build number
   - No manual version updates needed!

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **Major** (v2.0.0): Breaking changes or major new features
- **Minor** (v1.2.0): New features, backward compatible
- **Patch** (v1.0.1): Bug fixes, backward compatible

### How It Works

The `ci_scripts/ci_post_clone.sh` script runs during Xcode Cloud builds:
1. Reads the `CI_TAG` environment variable (e.g., "v1.2.0")
2. Strips the "v" prefix → "1.2.0"
3. Updates `MARKETING_VERSION` in project.pbxproj
4. Updates `CURRENT_PROJECT_VERSION` to CI build number
