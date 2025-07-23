#!/bin/bash

# Always operate from the script’s own folder
cd "$(dirname "$0")"

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

# Ask to delete the ZIP file (if it exists in parent directory)
PARENT_DIR="$(dirname "$(pwd)")"
ZIP_PATH="$PARENT_DIR/$ZIP_NAME"

if [ -f "$ZIP_PATH" ]; then
  echo ""
  read -p "🗑️  Do you want to delete the original ZIP file ($ZIP_NAME)? [y/N]: " DELETE_ZIP
  if [[ "$DELETE_ZIP" =~ ^[Yy]$ ]]; then
    rm "$ZIP_PATH"
    echo "🗑️  ZIP file deleted."
  else
    echo "📦 ZIP file kept."
  fi
fi

# Ask to delete this script
SCRIPT_NAME=$(basename "$0")
echo ""
read -p "🧼 Do you want to delete this launcher script ($SCRIPT_NAME)? [y/N]: " DELETE_ME
if [[ "$DELETE_ME" =~ ^[Yy]$ ]]; then
  rm -- "$0"
  echo "🧼 Launcher script deleted."
else
  echo "📂 Launcher script kept."
fi

# Close Terminal completely
sleep 3
osascript -e 'tell application "Terminal" to quit'

exit 0
