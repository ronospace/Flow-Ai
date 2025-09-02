#!/bin/bash

# Script to convert iOS simulator screenshots to Android Play Store format
echo "📱 Converting iOS Screenshots to Android Play Store Format"
echo ""

# Create directory for converted screenshots
mkdir -p ~/Desktop/PlayStore_Screenshots

echo "🔍 Looking for recent screenshots on Desktop..."
cd ~/Desktop

# Find recent screenshot files
screenshots=($(ls -t Screenshot*.png 2>/dev/null | head -8))

if [ ${#screenshots[@]} -eq 0 ]; then
    echo "❌ No screenshots found on Desktop"
    echo "💡 Take screenshots using Cmd+S in the iOS Simulator first"
    exit 1
fi

echo "📸 Found ${#screenshots[@]} screenshot(s):"
for screenshot in "${screenshots[@]}"; do
    echo "   • $screenshot"
done
echo ""

counter=1
for screenshot in "${screenshots[@]}"; do
    if [ $counter -gt 8 ]; then
        echo "⚠️  Only processing first 8 screenshots (Play Store limit)"
        break
    fi
    
    echo "🔄 Converting screenshot $counter: $screenshot"
    
    # Get original dimensions
    original_size=$(sips -g pixelWidth -g pixelHeight "$screenshot" | tail -2 | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    echo "   📐 Original size: $original_size"
    
    # Convert to phone-like dimensions (9:16 aspect ratio, minimum 1080px)
    # Target: 1080x1920 (good for Play Store)
    output_name="~/Desktop/PlayStore_Screenshots/screenshot_${counter}.png"
    
    # Crop and resize to 1080x1920
    sips -z 1920 1080 "$screenshot" --out "$output_name" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Converted to 1080x1920: screenshot_${counter}.png"
    else
        echo "   ❌ Failed to convert $screenshot"
    fi
    
    ((counter++))
done

echo ""
echo "🎉 Conversion complete!"
echo "📁 Converted screenshots saved to: ~/Desktop/PlayStore_Screenshots/"
echo "📱 These screenshots are ready for Google Play Store upload"
echo ""

# Open the folder
open ~/Desktop/PlayStore_Screenshots/

echo "💡 Upload instructions:"
echo "   1. Go back to Play Console in your browser"
echo "   2. Drag and drop the converted screenshots"
echo "   3. Make sure you have 2-8 screenshots total"
echo "   4. Each screenshot should show a different app screen"
