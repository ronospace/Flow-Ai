#!/bin/bash

# Script to convert Mac screenshots to App Store required sizes
echo "💻 Converting Mac Screenshots for App Store Submission"
echo ""

# Create directory for converted Mac screenshots
mkdir -p ~/Desktop/MacAppStore_Screenshots

echo "🔍 Looking for recent Mac screenshots on Desktop..."
cd ~/Desktop

# Find recent screenshot files (look for newer ones)
screenshots=($(ls -t Screenshot*.png CleanShot*.png flowsense*.png 2>/dev/null | head -10))

if [ ${#screenshots[@]} -eq 0 ]; then
    echo "❌ No screenshots found on Desktop"
    echo "💡 Take screenshots of your running Flow AI app first:"
    echo "   1. Use Cmd+Shift+4, then press Space"
    echo "   2. Click on your Flow AI app window"
    echo "   3. Run this script again"
    exit 1
fi

echo "📸 Found ${#screenshots[@]} screenshot(s):"
for screenshot in "${screenshots[@]}"; do
    if [[ -f "$screenshot" ]]; then
        size=$(sips -g pixelWidth -g pixelHeight "$screenshot" 2>/dev/null | tail -2 | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        echo "   • $screenshot ($size)"
    fi
done
echo ""

echo "🎯 Creating Mac App Store sized screenshots..."
echo ""

# Mac App Store required sizes
declare -a sizes=("1280x800" "1440x900" "2560x1600" "2880x1800")
declare -a size_names=("1280x800" "1440x900" "2560x1600" "2880x1800")

counter=1
for screenshot in "${screenshots[@]}"; do
    if [[ ! -f "$screenshot" ]]; then
        continue
    fi
    
    if [ $counter -gt 10 ]; then
        echo "⚠️  Only processing first 10 screenshots (App Store limit)"
        break
    fi
    
    echo "🔄 Processing screenshot $counter: $screenshot"
    
    # Create all required sizes for this screenshot
    for i in "${!sizes[@]}"; do
        size=${sizes[$i]}
        size_name=${size_names[$i]}
        width=$(echo $size | cut -d'x' -f1)
        height=$(echo $size | cut -d'x' -f2)
        
        output_name="MacAppStore_Screenshots/mac_${size_name}_screenshot_${counter}.png"
        
        echo "   📐 Creating ${size_name}: $output_name"
        
        # Convert to required size
        sips -z $height $width "$screenshot" --out "$output_name" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo "   ✅ Created ${size_name} version"
        else
            echo "   ❌ Failed to create ${size_name} version"
        fi
    done
    
    echo ""
    ((counter++))
done

echo "🎉 Mac screenshot conversion complete!"
echo "📁 Converted screenshots saved to: ~/Desktop/MacAppStore_Screenshots/"
echo "💻 These screenshots are ready for Mac App Store upload"
echo ""

# Open the folder
open ~/Desktop/MacAppStore_Screenshots/

echo "📋 Upload instructions:"
echo "   1. Go to App Store Connect"
echo "   2. Find the macOS app section"
echo "   3. Upload up to 10 screenshots and 3 app previews"
echo "   4. Use screenshots that show your best features"
echo ""

echo "📱 Available sizes created:"
for size_name in "${size_names[@]}"; do
    echo "   • $size_name screenshots"
done
