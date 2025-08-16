#!/bin/bash

# FlowSense Quick Deployment Launcher
# This script provides a simple interface to deploy FlowSense

clear
echo "🚀 FlowSense Deployment Launcher"
echo "================================"
echo ""
echo "Choose deployment option:"
echo ""
echo "1. 🌐 Deploy to Web (Firebase/Netlify/Vercel)"
echo "2. 🤖 Build for Android (Google Play Store)"
echo "3. 📱 Build for iOS (App Store)"
echo "4. 🎯 Build All Platforms"
echo "5. 📋 View Deployment Guide"
echo "6. ❌ Exit"
echo ""
read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo ""
        echo "🌐 Starting Web Deployment..."
        ./scripts/deploy-web.sh
        ;;
    2)
        echo ""
        echo "🤖 Starting Android Build..."
        ./scripts/deploy-android.sh
        ;;
    3)
        echo ""
        echo "📱 Starting iOS Build..."
        ./scripts/deploy-ios.sh
        ;;
    4)
        echo ""
        echo "🎯 Starting Multi-Platform Build..."
        ./scripts/deploy-all.sh
        ;;
    5)
        echo ""
        echo "📋 Opening Deployment Guide..."
        if command -v code &> /dev/null; then
            code DEPLOYMENT_GUIDE.md
        elif command -v open &> /dev/null; then
            open DEPLOYMENT_GUIDE.md
        else
            cat DEPLOYMENT_GUIDE.md
        fi
        ;;
    6)
        echo ""
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Invalid choice. Please select 1-6."
        exit 1
        ;;
esac
