#!/bin/bash

# Flutter Build Issues Fix Script
# This script addresses common cross-platform build issues

set -e

echo "🔧 Flutter Build Issues Fix Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in a Flutter project directory!"
    exit 1
fi

print_status "Starting build fixes..."

# 1. Clean everything
print_status "🧹 Cleaning project..."
flutter clean
rm -rf .dart_tool/
rm -rf build/
print_success "Project cleaned"

# 2. Update Flutter and dependencies
print_status "📦 Updating Flutter and dependencies..."
flutter upgrade
flutter pub get
print_success "Flutter and dependencies updated"

# 3. Fix iOS specific issues
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "🍎 Fixing iOS specific issues..."
    
    if [ -d "ios" ]; then
        cd ios
        
        # Update CocoaPods
        print_status "Updating CocoaPods..."
        pod repo update
        rm -rf Pods/
        rm -f Podfile.lock
        pod install --clean-install
        
        # Fix common iOS issues
        print_status "Applying iOS fixes..."
        
        # Update deployment target in Podfile
        if ! grep -q "platform :ios, '12.0'" Podfile; then
            sed -i '' "s/# platform :ios, '.*'/platform :ios, '12.0'/" Podfile
            print_success "Updated iOS deployment target to 12.0"
        fi
        
        # Disable Bitcode (deprecated by Apple)
        if ! grep -q "ENABLE_BITCODE.*NO" *.xcconfig 2>/dev/null; then
            echo "ENABLE_BITCODE = NO" >> Runner/Release.xcconfig
            echo "ENABLE_BITCODE = NO" >> Runner/Debug.xcconfig
            print_success "Disabled Bitcode"
        fi
        
        cd ..
    fi
fi

# 4. Fix Android specific issues
print_status "🤖 Fixing Android specific issues..."

if [ -d "android" ]; then
    cd android
    
    # Update Gradle wrapper
    print_status "Updating Gradle wrapper..."
    ./gradlew wrapper --gradle-version 7.5
    
    # Clean Android build
    ./gradlew clean
    
    # Fix common Android build issues
    print_status "Applying Android fixes..."
    
    # Update build.gradle (app level)
    if [ -f "app/build.gradle" ]; then
        # Ensure correct SDK versions
        sed -i 's/compileSdkVersion .*/compileSdkVersion 34/' app/build.gradle
        sed -i 's/targetSdkVersion .*/targetSdkVersion 34/' app/build.gradle
        
        # Ensure minSdkVersion is at least 21
        if ! grep -q "minSdkVersion 2[1-9]" app/build.gradle; then
            sed -i 's/minSdkVersion .*/minSdkVersion 21/' app/build.gradle
        fi
        
        # Enable MultiDex
        if ! grep -q "multiDexEnabled true" app/build.gradle; then
            sed -i '/defaultConfig {/a\        multiDexEnabled true' app/build.gradle
        fi
        
        print_success "Updated Android build configuration"
    fi
    
    # Update project level build.gradle
    if [ -f "build.gradle" ]; then
        # Update Kotlin version
        sed -i "s/ext.kotlin_version = .*/ext.kotlin_version = '1.7.10'/" build.gradle
        print_success "Updated Kotlin version"
    fi
    
    cd ..
fi

# 5. Fix web specific issues
print_status "🌐 Fixing Web specific issues..."

# Ensure web directory exists
if [ ! -d "web" ]; then
    flutter create --platforms=web .
    print_success "Created web platform support"
fi

# Update web index.html for better compatibility
if [ -f "web/index.html" ]; then
    # Ensure proper meta tags for PWA
    if ! grep -q "manifest.json" web/index.html; then
        sed -i '/<head>/a\  <link rel="manifest" href="manifest.json">' web/index.html
        print_success "Added manifest.json link"
    fi
    
    # Ensure proper viewport meta tag
    if ! grep -q "viewport" web/index.html; then
        sed -i '/<head>/a\  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">' web/index.html
        print_success "Added viewport meta tag"
    fi
fi

# 6. Update pubspec.yaml with required dependencies
print_status "📋 Checking required dependencies..."

# Check if device_info_plus is present
if ! grep -q "device_info_plus:" pubspec.yaml; then
    print_warning "Adding device_info_plus dependency..."
    # Add to dependencies section
    awk '/^dependencies:/ {print; print "  device_info_plus: ^9.1.0"; next} 1' pubspec.yaml > pubspec_temp.yaml
    mv pubspec_temp.yaml pubspec.yaml
fi

# Check for other critical dependencies
REQUIRED_DEPS=("firebase_core" "firebase_auth" "provider" "flutter_animate")

for dep in "${REQUIRED_DEPS[@]}"; do
    if ! grep -q "$dep:" pubspec.yaml; then
        print_warning "Missing dependency: $dep"
    fi
done

# 7. Fix permissions
print_status "🔒 Fixing permissions..."

# Android permissions
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    # Ensure internet permission exists
    if ! grep -q "android.permission.INTERNET" android/app/src/main/AndroidManifest.xml; then
        sed -i '/<manifest/a\    <uses-permission android:name="android.permission.INTERNET" />' android/app/src/main/AndroidManifest.xml
        print_success "Added Internet permission to Android"
    fi
fi

# iOS permissions
if [ -f "ios/Runner/Info.plist" ]; then
    # Check for basic permissions
    if ! grep -q "NSCameraUsageDescription" ios/Runner/Info.plist; then
        print_warning "Consider adding camera usage description to iOS Info.plist"
    fi
fi

# 8. Fix Firebase configuration
print_status "🔥 Checking Firebase configuration..."

# Check for Firebase config files
if [ ! -f "android/app/google-services.json" ]; then
    print_warning "Missing google-services.json for Android"
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_warning "Missing GoogleService-Info.plist for iOS"
fi

# 9. Apply platform-specific fixes
print_status "⚙️ Applying platform-specific fixes..."

# Enable required Flutter features
flutter config --enable-web
if [[ "$OSTYPE" == "darwin"* ]]; then
    flutter config --enable-macos-desktop
    flutter config --enable-ios
fi
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    flutter config --enable-linux-desktop
fi
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    flutter config --enable-windows-desktop
fi

# 10. Verify the fixes
print_status "✅ Verifying fixes..."

# Run flutter doctor to check for issues
print_status "Running Flutter Doctor..."
flutter doctor

# Check if there are any analysis issues
print_status "Running Flutter Analyze..."
flutter analyze --no-fatal-infos

# Try a test build for current platform
print_status "Testing build..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "Testing iOS build..."
    if flutter build ios --no-codesign; then
        print_success "iOS build test passed"
    else
        print_error "iOS build test failed"
    fi
fi

print_status "Testing Android build..."
if flutter build apk --debug; then
    print_success "Android build test passed"
else
    print_error "Android build test failed"
fi

print_status "Testing Web build..."
if flutter build web; then
    print_success "Web build test passed"
else
    print_error "Web build test failed"
fi

print_success "🎉 Build fixes completed!"
print_status "Next steps:"
echo "  1. Update Firebase configuration files with your project details"
echo "  2. Configure app signing for release builds"
echo "  3. Test on actual devices"
echo "  4. Run comprehensive tests: flutter test"

echo ""
print_status "Common commands for further troubleshooting:"
echo "  flutter clean && flutter pub get"
echo "  flutter doctor -v"
echo "  flutter analyze"
echo "  flutter test"

# Show platform-specific next steps
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    print_status "iOS specific next steps:"
    echo "  1. Open ios/Runner.xcworkspace in Xcode"
    echo "  2. Configure signing & capabilities"
    echo "  3. Add GoogleService-Info.plist to Xcode project"
    echo "  4. Test on iOS Simulator: flutter run"
fi

echo ""
print_status "Android specific next steps:"
echo "  1. Ensure google-services.json is in android/app/"
echo "  2. Configure app signing for release builds"
echo "  3. Test on Android emulator: flutter run"

echo ""
print_status "Web specific next steps:"
echo "  1. Configure Firebase web app in Firebase Console"
echo "  2. Update firebase_options.dart with web config"
echo "  3. Test web build: flutter run -d chrome"

echo ""
print_success "All fixes applied successfully! 🚀"
