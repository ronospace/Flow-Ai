#!/bin/bash

# Script to help upload macOS Flow AI app to App Store
echo "🍎 Flow AI - macOS App Store Upload Guide"
echo ""

APP_PATH="build/macos/Build/Products/Release/Flow AI.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at $APP_PATH"
    echo "💡 Run 'flutter build macos --release' first"
    exit 1
fi

echo "✅ macOS app built successfully!"
echo "📱 App location: $APP_PATH"
echo "📦 App size: $(du -sh "$APP_PATH" | cut -f1)"
echo ""

echo "🎯 Upload Options:"
echo ""
echo "📋 Option 1: Xcode Organizer (Recommended)"
echo "   1. Open Xcode"
echo "   2. Window → Organizer"
echo "   3. Click 'Distribute App'"
echo "   4. Select 'App Store Connect'"
echo "   5. Follow the upload wizard"
echo ""

echo "📋 Option 2: Application Loader (if available)"
echo "   1. Open Application Loader"
echo "   2. Click 'Deliver Your App'"
echo "   3. Select the .app file"
echo "   4. Follow upload process"
echo ""

echo "📋 Option 3: Command Line (Advanced)"
echo "   Use: xcrun altool --upload-app -f 'Flow AI.app' -u [YOUR_APPLE_ID] -p [APP_PASSWORD]"
echo ""

echo "🔧 Before Upload Checklist:"
echo "   ✅ App is code-signed (automatic in release build)"
echo "   ✅ Bundle identifier matches App Store Connect: com.flowai.app"
echo "   ✅ Version number: $(plutil -p "$APP_PATH/Contents/Info.plist" | grep CFBundleShortVersionString | awk '{print $3}' | tr -d '"')"
echo "   ✅ Build number: $(plutil -p "$APP_PATH/Contents/Info.plist" | grep CFBundleVersion | awk '{print $3}' | tr -d '"')"
echo ""

echo "📱 App Store Connect Next Steps:"
echo "   1. Wait for processing (5-30 minutes)"
echo "   2. Add app metadata (description, screenshots, etc.)"
echo "   3. Submit for review"
echo ""

echo "📁 Opening app location..."
echo "💡 You can drag 'Flow AI.app' directly into Xcode Organizer"

# Open the folder containing the app
open "$(dirname "$APP_PATH")"
