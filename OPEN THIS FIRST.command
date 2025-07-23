#!/bin/bash

APP_NAME="lightroom-template-helper.app"
ZIP_NAME="lightroom-template.zip"

clear
echo ""
echo "🚀 Preparing to launch Lightroom Templates Generator..."
echo ""

# Check if the .app exists
if [ ! -d "$APP_NAME" ]; then
  echo "❌ ERROR: $APP_NAME not found in this folder."
  echo "Make sure this file and the app are in the same location."
  sleep 5
  exit 1
fi

# Remove quarantine flag
echo "🧹 Removing macOS quarantine flag..."
xattr -rd com.apple.quarantine "$APP_NAME"

# Launch the app
echo "📂 Launching the app..."
open "$APP_NAME"

# Ask to delete the zip file (if it exists)
if [ -f "$ZIP_NAME" ]; then
  echo ""
  read -p "🗑️  Do you want to delete the original ZIP file ($ZIP_NAME)? [y/N]: " DELETE_ZIP
  if [[ "$DELETE_ZIP" =~ ^[Yy]$ ]]; then
    rm "$ZIP_NAME"
    echo "🗑️  ZIP file deleted."
  else
    echo "📦 ZIP file kept."
  fi
fi

# Wait a moment then close Terminal
sleep 3
osascript -e 'tell application "Terminal" to close (every window whose name contains \"OPEN THIS FIRST\")' &>/dev/null &

exit 0
