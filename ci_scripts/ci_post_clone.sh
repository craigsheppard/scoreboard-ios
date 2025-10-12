#!/usr/bin/env bash

set -e
set -x

echo "Running Xcode Cloud post-clone script"

if [ -n "$CI_TAG" ]; then
  # Get the tag name from environment (set by Xcode Cloud)
  TAG_NAME="${CI_TAG}"

  # Strip off the leading "v" from the tag name
  TAG_NAME=${TAG_NAME#v}

  # Define the path to project.pbxproj file
  PROJECT_FILE="${CI_PRIMARY_REPOSITORY_PATH}/Scoreboard ∞.xcodeproj/project.pbxproj"

  echo "Setting version from tag: $TAG_NAME"

  # Update MARKETING_VERSION (user-facing version)
  sed -i '' "s/MARKETING_VERSION = [^;]*/MARKETING_VERSION = $TAG_NAME/" "$PROJECT_FILE"

  # Update CURRENT_PROJECT_VERSION (build number) with Xcode Cloud build number
  sed -i '' "s/CURRENT_PROJECT_VERSION = [^;]*/CURRENT_PROJECT_VERSION = $CI_BUILD_NUMBER/" "$PROJECT_FILE"

  echo "✓ Updated project.pbxproj:"
  echo "  MARKETING_VERSION: $TAG_NAME"
  echo "  CURRENT_PROJECT_VERSION: $CI_BUILD_NUMBER"
else
  echo "No CI_TAG found, skipping version update"
fi
