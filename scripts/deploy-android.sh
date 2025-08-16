#!/bin/bash

# FlowSense Android Deployment Script
# This script builds the Android app for Google Play Store

set -e  # Exit on any error

echo "🤖 FlowSense Android Deployment"
echo "==============================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
print_status "Checking Flutter version..."
flutter --version

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Generate localization files
print_status "Generating localization files..."
flutter gen-l10n

# Run analyzer to check for issues
print_status "Running Flutter analyzer..."
if ! flutter analyze; then
    print_error "Flutter analyzer found issues. Please fix them before deploying."
    exit 1
fi

print_success "Analysis completed successfully"

# Check if signing key is configured
if [ ! -f "android/key.properties" ]; then
    print_warning "Signing key not configured!"
    echo ""
    echo "To set up app signing:"
    echo "1. Generate a signing key:"
    echo "   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
    echo ""
    echo "2. Create android/key.properties with:"
    echo "   storePassword=<password>"
    echo "   keyPassword=<password>"
    echo "   keyAlias=upload"
    echo "   storeFile=<path-to-keystore>"
    echo ""
    echo "3. Update android/app/build.gradle to use the signing config"
    echo ""
    print_status "Building unsigned APK for testing..."
    flutter build apk --release
    print_success "Unsigned APK built successfully at: build/app/outputs/flutter-apk/app-release.apk"
    exit 0
fi

print_status "Signing key found. Building signed app..."

# Ask user what type of build they want
echo ""
echo "Select build type:"
echo "1. APK (for testing or direct distribution)"
echo "2. App Bundle (recommended for Google Play Store)"
echo "3. Both"
echo ""
read -p "Enter your choice (1-3): " build_choice

case $build_choice in
    1)
        print_status "Building APK..."
        flutter build apk --release
        print_success "APK built successfully!"
        print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    2)
        print_status "Building App Bundle..."
        flutter build appbundle --release
        print_success "App Bundle built successfully!"
        print_status "App Bundle location: build/app/outputs/bundle/release/app-release.aab"
        ;;
    3)
        print_status "Building APK..."
        flutter build apk --release
        print_success "APK built successfully!"
        
        print_status "Building App Bundle..."
        flutter build appbundle --release
        print_success "App Bundle built successfully!"
        
        print_status "Build artifacts:"
        print_status "APK: build/app/outputs/flutter-apk/app-release.apk"
        print_status "App Bundle: build/app/outputs/bundle/release/app-release.aab"
        ;;
    *)
        print_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Provide next steps
echo ""
echo "📋 Next Steps for Google Play Store:"
echo "====================================="
echo "1. Go to Google Play Console (play.google.com/console)"
echo "2. Create a new app or select existing app"
echo "3. Upload the App Bundle (.aab file) - recommended"
echo "4. Fill out store listing information"
echo "5. Set up content rating and target audience"
echo "6. Configure app pricing and distribution"
echo "7. Submit for review"
echo ""
echo "📊 App Bundle Benefits:"
echo "- Smaller download size for users"
echo "- Dynamic delivery features"
echo "- Better optimization by Google Play"
echo ""

print_success "Android deployment script completed! 🎉"
