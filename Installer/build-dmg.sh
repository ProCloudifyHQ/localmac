#!/bin/bash
set -e

VERSION=${1:-"1.0.0"}
APP_NAME="Localmac"
SCHEME="Localmac"
BUILD_DIR="$(pwd)/.build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
DMG_PATH="$BUILD_DIR/$APP_NAME-v$VERSION.dmg"

echo "▶ Building $APP_NAME v$VERSION..."

# Clean
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build archive
xcodebuild archive \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  | xcpretty || xcodebuild archive \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Export app
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist Installer/ExportOptions-unsigned.plist

# Install create-dmg if needed
if ! command -v create-dmg &>/dev/null; then
  echo "▶ Installing create-dmg..."
  brew install create-dmg
fi

# Create DMG
echo "▶ Creating DMG..."
create-dmg \
  --volname "$APP_NAME" \
  --volicon "Localmac/Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" \
  --window-pos 200 120 \
  --window-size 540 380 \
  --icon-size 128 \
  --icon "$APP_NAME.app" 130 170 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 410 170 \
  --no-internet-enable \
  "$DMG_PATH" \
  "$EXPORT_PATH/$APP_NAME.app" || \
create-dmg \
  --volname "$APP_NAME" \
  --window-size 540 380 \
  --icon-size 128 \
  --icon "$APP_NAME.app" 130 170 \
  --app-drop-link 410 170 \
  "$DMG_PATH" \
  "$EXPORT_PATH/$APP_NAME.app"

echo ""
echo "✅ Done: $DMG_PATH"
echo ""
echo "To release:"
echo "  1. git tag v$VERSION && git push origin v$VERSION"
echo "  2. Upload $DMG_PATH to GitHub Releases"
echo "  3. brew update (auto via CI)"
