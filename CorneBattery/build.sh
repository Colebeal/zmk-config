#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="CorneBattery"
BUNDLE_ID="com.cbeal.CorneBattery"
INSTALL_DIR="$HOME/Applications"
SRC_DIR="CorneBattery"
STAGE="$(mktemp -d)"
APP="$STAGE/$APP_NAME.app"

swift build -c release

mkdir -p "$APP/Contents/MacOS"
cp ".build/release/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"
cp "$SRC_DIR/Info.plist" "$APP/Contents/Info.plist"

codesign --force --sign - \
  --entitlements "$SRC_DIR/$APP_NAME.entitlements" \
  "$APP"

mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/$APP_NAME.app"
mv "$APP" "$INSTALL_DIR/$APP_NAME.app"
rm -rf "$STAGE"

echo "Installed: $INSTALL_DIR/$APP_NAME.app"
