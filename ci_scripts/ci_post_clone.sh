#!/usr/bin/env bash

set -e
set -x

echo "Running Xcode Cloud post-clone script"

if [ -n "$CI_TAG" ]; then
  # Get the tag name from environment (set by Xcode Cloud)
  TAG_NAME="${CI_TAG}"

  # Strip off the leading "v" from the tag name
  TAG_NAME=${TAG_NAME#v}

  # Define the path to Info.plist file
  PLIST_PATH="${CI_PRIMARY_REPOSITORY_PATH}/scoreboard/Info.plist"

  echo "Setting version from tag: $TAG_NAME"

  # Add or update CFBundleShortVersionString (user-facing version)
  /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $TAG_NAME" "$PLIST_PATH" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $TAG_NAME" "$PLIST_PATH"

  # Add or update CFBundleVersion (build number) with Xcode Cloud build number
  /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $CI_BUILD_NUMBER" "$PLIST_PATH" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $CI_BUILD_NUMBER" "$PLIST_PATH"

  echo "✓ Updated Info.plist:"
  echo "  Version: $TAG_NAME"
  echo "  Build: $CI_BUILD_NUMBER"
else
  echo "No CI_TAG found, skipping version update"
fi
