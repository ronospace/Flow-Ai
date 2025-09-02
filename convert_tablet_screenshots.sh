#!/bin/bash

# Script to convert iPad screenshots to 7-inch tablet format for Play Store
echo "📱 Converting iPad Screenshots to 7-inch Tablet Play Store Format"
echo ""

# Create directory for converted tablet screenshots
mkdir -p ~/Desktop/PlayStore_TabletScreenshots

echo "🔍 Looking for recent iPad screenshots on Desktop..."
cd ~/Desktop

# Find recent screenshot files (looking for newer ones since we just launched iPad)
screenshots=($(ls -t Screenshot*.png 2>/dev/null | head -8))

if [ ${#screenshots[@]} -eq 0 ]; then
    echo "❌ No screenshots found on Desktop"
    echo "💡 Take screenshots using Cmd+S in the iPad Simulator first"
    echo "📋 Steps:"
    echo "   1. Navigate to different screens in the iPad app"
    echo "   2. Press Cmd+S to take screenshots"
    echo "   3. Run this script again"
    exit 1
fi

echo "📸 Found ${#screenshots[@]} screenshot(s):"
for screenshot in "${screenshots[@]}"; do
    size=$(sips -g pixelWidth -g pixelHeight "$screenshot" | tail -2 | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    echo "   • $screenshot ($size)"
done
echo ""

echo "🎯 Will convert tablet screenshots to 1600x2560 (optimal for 7-inch tablets)"
echo ""

counter=1
for screenshot in "${screenshots[@]}"; do
    if [ $counter -gt 8 ]; then
        echo "⚠️  Only processing first 8 screenshots (Play Store limit)"
        break
    fi
    
    # Get dimensions to check if it's likely an iPad screenshot
    width=$(sips -g pixelWidth "$screenshot" | tail -1 | awk '{print $2}')
    height=$(sips -g pixelHeight "$screenshot" | tail -1 | awk '{print $2}')
    
    # Skip if it looks like a phone screenshot (too narrow)
    aspect_ratio=$(echo "scale=2; $width/$height" | bc -l 2>/dev/null || echo "0")
    if (( $(echo "$aspect_ratio < 0.6" | bc -l 2>/dev/null || echo "1") )); then
        echo "⏭️  Skipping $screenshot (appears to be phone screenshot, aspect ratio: $aspect_ratio)"
        continue
    fi
    
    echo "🔄 Converting tablet screenshot $counter: $screenshot"
    echo "   📐 Original size: ${width}x${height} (aspect ratio: $aspect_ratio)"
    
    # Convert to 7-inch tablet dimensions
    # Target: 1600x2560 for portrait, or 2560x1600 for landscape
    output_name="~/Desktop/PlayStore_TabletScreenshots/tablet_screenshot_${counter}.png"
    
    # Determine orientation and convert accordingly
    if [ "$width" -gt "$height" ]; then
        # Landscape orientation
        echo "   🔄 Converting landscape to 2560x1600"
        sips -z 1600 2560 "$screenshot" --out "$output_name" > /dev/null 2>&1
        target_size="2560x1600"
    else
        # Portrait orientation  
        echo "   🔄 Converting portrait to 1600x2560"
        sips -z 2560 1600 "$screenshot" --out "$output_name" > /dev/null 2>&1
        target_size="1600x2560"
    fi
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Converted to $target_size: tablet_screenshot_${counter}.png"
    else
        echo "   ❌ Failed to convert $screenshot"
    fi
    
    ((counter++))
done

echo ""
echo "🎉 Tablet screenshot conversion complete!"
echo "📁 Converted screenshots saved to: ~/Desktop/PlayStore_TabletScreenshots/"
echo "📱 These screenshots are ready for Google Play Store 7-inch tablet upload"
echo ""

# Open the folder
open ~/Desktop/PlayStore_TabletScreenshots/

echo "💡 Upload instructions:"
echo "   1. Go back to Play Console in your browser"
echo "   2. Find the '7-inch tablet screenshots' section"
echo "   3. Drag and drop the converted tablet screenshots"
echo "   4. Make sure you have up to 8 tablet screenshots"
echo "   5. Each screenshot should show a different app screen on tablet"
