#!/bin/bash

# Flow Ai Icon Generator
# Generates all required iOS app icon sizes from SVG source

echo "🎨 Generating Flow Ai App Icons..."

# Create directories
mkdir -p assets/icons/ios
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

# Source SVG file
SVG_FILE="assets/icons/flowai_icon.svg"

if [ ! -f "$SVG_FILE" ]; then
    echo "❌ Error: SVG source file not found at $SVG_FILE"
    exit 1
fi

# Check if rsvg-convert is available (for SVG to PNG conversion)
if ! command -v rsvg-convert &> /dev/null; then
    echo "📦 Installing librsvg for SVG conversion..."
    brew install librsvg
fi

# iOS App Icon sizes (width x height @ scale)
declare -a SIZES=(
    "20:20x20"      # iPhone Notification iOS 7-14
    "40:20x20@2x"   # iPhone Notification iOS 7-14
    "60:20x20@3x"   # iPhone Notification iOS 7-14
    "29:29x29"      # iPhone Settings iOS 5,6 Spotlight iOS 5-10
    "58:29x29@2x"   # iPhone Settings iOS 5-14 Spotlight iOS 5-10
    "87:29x29@3x"   # iPhone Settings iOS 5-14 Spotlight iOS 5-10
    "40:40x40"      # iPhone Spotlight iOS 7-14
    "80:40x40@2x"   # iPhone Spotlight iOS 7-14
    "120:40x40@3x"  # iPhone Spotlight iOS 7-14
    "120:60x60@2x"  # iPhone App iOS 7-14
    "180:60x60@3x"  # iPhone App iOS 7-14
    "1024:1024x1024" # App Store
)

echo "🔄 Converting SVG to PNG formats..."

for size_info in "${SIZES[@]}"; do
    IFS=':' read -r px_size name <<< "$size_info"
    
    echo "   📱 Generating ${name} (${px_size}px)"
    
    # Generate PNG
    rsvg-convert -w $px_size -h $px_size \
        "$SVG_FILE" \
        -o "assets/icons/ios/icon_${px_size}.png"
    
    # Copy to iOS assets with proper naming
    cp "assets/icons/ios/icon_${px_size}.png" \
       "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-${name}.png"
done

echo "📝 Generating Contents.json for iOS..."

# Create Contents.json for iOS App Icons
cat > "ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "Icon-20x20.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20x20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-20x20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-29x29.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29x29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-29x29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-40x40.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40x40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-40x40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-60x60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-60x60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-1024x1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✨ Icon generation complete!"
echo "📍 Icons saved to:"
echo "   • assets/icons/ios/ (PNG files)"
echo "   • ios/Runner/Assets.xcassets/AppIcon.appiconset/ (iOS bundle)"
echo ""
echo "🎯 Next steps:"
echo "   1. Review the generated 1024px icon: assets/icons/ios/icon_1024.png"
echo "   2. Open Xcode and verify the AppIcon set is properly configured"
echo "   3. Build and test on device to see the new icon in action"
echo ""
echo "🎨 Your new Dual Arc Flow icon is ready for Flow Ai!"
