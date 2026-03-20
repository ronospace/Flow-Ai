#!/bin/bash

# Script to help take Mac App Store screenshots
echo "💻 Flow AI - Mac App Store Screenshot Guide"
echo ""

# Create directory for Mac screenshots
mkdir -p ~/Desktop/MacAppStore_Screenshots

echo "📱 Your Flow AI app should be running on macOS now!"
echo ""
echo "🎯 Required Mac App Store screenshot sizes:"
echo "   • 1280 × 800px (16:10 aspect ratio)"
echo "   • 1440 × 900px (16:10 aspect ratio)"  
echo "   • 2560 × 1600px (16:10 aspect ratio)"
echo "   • 2880 × 1800px (16:10 aspect ratio)"
echo ""

echo "📋 How to take screenshots:"
echo "1. 📱 Navigate to different screens in your running Flow AI app"
echo "2. 📸 Use Cmd+Shift+4 then press Space to capture the window"
echo "3. 🖱️  Click on your Flow AI app window to capture it"
echo "4. 📁 Screenshots will be saved to your Desktop"
echo ""

echo "🔧 After taking screenshots, run:"
echo "   ./convert_mac_screenshots.sh"
echo ""

echo "💡 Recommended screenshots to take:"
echo "   • Welcome/Authentication screen"
echo "   • Home dashboard"
echo "   • Calendar/cycle tracking view" 
echo "   • Zyra AI chat interface"
echo "   • Analytics/insights dashboard"
echo "   • Settings screen"
echo ""

echo "⚡ Pro tip: Resize your app window to roughly match the Mac App Store ratios!"
echo "   For best results, make the window wider (16:10 ratio = width 1.6x height)"
