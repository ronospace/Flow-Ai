#!/bin/bash

# FlowSense Multi-Platform Deployment Script
# This script builds FlowSense for all supported platforms

set -e  # Exit on any error

echo "🚀 FlowSense Multi-Platform Deployment"
echo "======================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_platform() {
    echo -e "${PURPLE}[PLATFORM]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Display Flutter version
print_status "Flutter version:"
flutter --version

echo ""
print_status "🔧 Preparing build environment..."

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Generate localization files
print_status "Generating localization files..."
flutter gen-l10n

# Run analyzer
print_status "Running Flutter analyzer..."
if ! flutter analyze; then
    print_error "Flutter analyzer found issues. Please fix them before deploying."
    exit 1
fi

print_success "Pre-build checks completed successfully"

echo ""
echo "🎯 Select platforms to build:"
echo "1. Web only"
echo "2. Android only"
echo "3. iOS only (macOS required)"
echo "4. All mobile (Android + iOS)"
echo "5. All platforms (Web + Android + iOS)"
echo "6. Custom selection"
echo ""
read -p "Enter your choice (1-6): " platform_choice

# Initialize build flags
BUILD_WEB=false
BUILD_ANDROID=false
BUILD_IOS=false

case $platform_choice in
    1)
        BUILD_WEB=true
        ;;
    2)
        BUILD_ANDROID=true
        ;;
    3)
        BUILD_IOS=true
        ;;
    4)
        BUILD_ANDROID=true
        BUILD_IOS=true
        ;;
    5)
        BUILD_WEB=true
        BUILD_ANDROID=true
        BUILD_IOS=true
        ;;
    6)
        echo ""
        echo "Select platforms to build:"
        read -p "Build Web? (y/n): " web_choice
        if [[ $web_choice == "y" || $web_choice == "Y" ]]; then
            BUILD_WEB=true
        fi
        
        read -p "Build Android? (y/n): " android_choice
        if [[ $android_choice == "y" || $android_choice == "Y" ]]; then
            BUILD_ANDROID=true
        fi
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            read -p "Build iOS? (y/n): " ios_choice
            if [[ $ios_choice == "y" || $ios_choice == "Y" ]]; then
                BUILD_IOS=true
            fi
        else
            print_warning "iOS builds are only supported on macOS"
        fi
        ;;
    *)
        print_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Start building selected platforms
echo ""
print_status "🏗️ Starting builds for selected platforms..."

# Track build results
BUILDS_COMPLETED=()
BUILDS_FAILED=()

# Web Build
if [ "$BUILD_WEB" = true ]; then
    echo ""
    print_platform "Building for Web..."
    
    if flutter build web --release; then
        print_success "✅ Web build completed successfully!"
        BUILDS_COMPLETED+=("Web")
        print_status "Web build location: build/web/"
    else
        print_error "❌ Web build failed!"
        BUILDS_FAILED+=("Web")
    fi
fi

# Android Build
if [ "$BUILD_ANDROID" = true ]; then
    echo ""
    print_platform "Building for Android..."
    
    # Check if signing is configured
    if [ -f "android/key.properties" ]; then
        print_status "Signing key found. Building signed App Bundle..."
        if flutter build appbundle --release; then
            print_success "✅ Android App Bundle build completed successfully!"
            BUILDS_COMPLETED+=("Android (App Bundle)")
            print_status "App Bundle location: build/app/outputs/bundle/release/app-release.aab"
        else
            print_error "❌ Android App Bundle build failed!"
            BUILDS_FAILED+=("Android (App Bundle)")
        fi
        
        print_status "Building signed APK..."
        if flutter build apk --release; then
            print_success "✅ Android APK build completed successfully!"
            BUILDS_COMPLETED+=("Android (APK)")
            print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
        else
            print_error "❌ Android APK build failed!"
            BUILDS_FAILED+=("Android (APK)")
        fi
    else
        print_warning "No signing key found. Building unsigned APK..."
        if flutter build apk --release; then
            print_success "✅ Android APK build completed successfully (unsigned)!"
            BUILDS_COMPLETED+=("Android (APK - Unsigned)")
            print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
            print_warning "⚠️ APK is unsigned. Set up signing for production release."
        else
            print_error "❌ Android APK build failed!"
            BUILDS_FAILED+=("Android (APK)")
        fi
    fi
fi

# iOS Build
if [ "$BUILD_IOS" = true ]; then
    echo ""
    print_platform "Building for iOS..."
    
    # Check if on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "❌ iOS builds require macOS!"
        BUILDS_FAILED+=("iOS")
    else
        # Check if Xcode is available
        if ! command -v xcodebuild &> /dev/null; then
            print_error "❌ Xcode is not installed!"
            BUILDS_FAILED+=("iOS")
        else
            print_status "Building iOS app (no codesign)..."
            if flutter build ios --release --no-codesign; then
                print_success "✅ iOS build completed successfully!"
                BUILDS_COMPLETED+=("iOS")
                print_status "iOS build location: build/ios/iphoneos/Runner.app"
                print_warning "⚠️ iOS app needs to be signed and archived in Xcode for distribution."
            else
                print_error "❌ iOS build failed!"
                BUILDS_FAILED+=("iOS")
            fi
        fi
    fi
fi

# Build Summary
echo ""
echo "📊 Build Summary"
echo "==============="

if [ ${#BUILDS_COMPLETED[@]} -gt 0 ]; then
    echo ""
    print_success "✅ Completed Builds:"
    for build in "${BUILDS_COMPLETED[@]}"; do
        echo "   • $build"
    done
fi

if [ ${#BUILDS_FAILED[@]} -gt 0 ]; then
    echo ""
    print_error "❌ Failed Builds:"
    for build in "${BUILDS_FAILED[@]}"; do
        echo "   • $build"
    done
fi

echo ""
echo "📋 Build Artifacts:"
echo "=================="

# List build artifacts
if [ "$BUILD_WEB" = true ] && [ -d "build/web" ]; then
    echo "🌐 Web: build/web/"
fi

if [ "$BUILD_ANDROID" = true ]; then
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        echo "🤖 Android App Bundle: build/app/outputs/bundle/release/app-release.aab"
    fi
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo "🤖 Android APK: build/app/outputs/flutter-apk/app-release.apk"
    fi
fi

if [ "$BUILD_IOS" = true ] && [ -d "build/ios/iphoneos/Runner.app" ]; then
    echo "📱 iOS App: build/ios/iphoneos/Runner.app"
fi

# Next Steps
echo ""
echo "🎯 Next Steps:"
echo "=============="

if [[ " ${BUILDS_COMPLETED[@]} " =~ " Web " ]]; then
    echo "🌐 Web Deployment:"
    echo "   • Firebase: firebase deploy --only hosting"
    echo "   • Netlify: Drag build/web folder to netlify.com"
    echo "   • Vercel: vercel --cwd build/web"
fi

if [[ " ${BUILDS_COMPLETED[@]} " =~ "Android" ]]; then
    echo "🤖 Android Deployment:"
    echo "   • Google Play Console: play.google.com/console"
    echo "   • Upload App Bundle (.aab) for optimal distribution"
    echo "   • APK for direct distribution or testing"
fi

if [[ " ${BUILDS_COMPLETED[@]} " =~ " iOS " ]]; then
    echo "📱 iOS Deployment:"
    echo "   • Open ios/Runner.xcworkspace in Xcode"
    echo "   • Archive and upload to App Store Connect"
    echo "   • appstoreconnect.apple.com"
fi

echo ""
if [ ${#BUILDS_FAILED[@]} -eq 0 ]; then
    print_success "🎉 All selected builds completed successfully!"
    echo ""
    echo "🌍 FlowSense is ready for deployment with 36-language support!"
else
    print_warning "⚠️ Some builds failed. Check the errors above and retry."
fi

print_success "Multi-platform deployment script completed! 🚀"
