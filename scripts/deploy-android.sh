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


# Verify required monetization backend endpoints are injected into release builds
print_status "Verifying monetization backend dart-defines..."
REQUIRED_DART_DEFINES=(
    FLOW_AI_RECEIPT_SERVICE_BASE_URL
)

for define_name in "${REQUIRED_DART_DEFINES[@]}"; do
    if [ -z "${!define_name:-}" ]; then
        print_error "Missing required release dart-define environment variable: ${define_name}"
        print_error "Refusing to build Android release without the Cloud Run receipt service base URL."
        exit 1
    fi
done

MONETIZATION_DART_DEFINES=(
    --dart-define=FLOW_AI_RECEIPT_SERVICE_BASE_URL="$FLOW_AI_RECEIPT_SERVICE_BASE_URL"
)

print_success "Monetization backend dart-defines are present"


# Verify Android release signing is configured before any release build
require_android_release_signing() {
    if [ ! -f "android/key.properties" ]; then
        print_error "Missing android/key.properties. Refusing unsigned Android release build."
        print_error "Create android/key.properties with storeFile, storePassword, keyAlias, and keyPassword."
        exit 1
    fi

    for signing_key in storeFile storePassword keyAlias keyPassword; do
        if ! grep -Eq "^[[:space:]]*${signing_key}[[:space:]]*=" android/key.properties; then
            print_error "Missing required Android release signing property: ${signing_key}"
            exit 1
        fi
    done

    signing_store_file="$(awk -F= '$1 ~ /^[[:space:]]*storeFile[[:space:]]*$/ {print $2}' android/key.properties | tail -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ -z "$signing_store_file" ]; then
        print_error "Android release signing storeFile is empty"
        exit 1
    fi

    if [ ! -f "android/${signing_store_file}" ] && [ ! -f "$signing_store_file" ]; then
        print_error "Android release signing keystore file is missing"
        exit 1
    fi

    print_success "Android release signing configuration is present"
}

# Run analyzer to check for issues
print_status "Running Flutter analyzer..."
if ! flutter analyze; then
    print_error "Flutter analyzer found issues. Please fix them before deploying."
    exit 1
fi

print_success "Analysis completed successfully"

# Check if signing key is configured
require_android_release_signing

print_status "Signing key found. Building signed app..."

# Ask user what type of build they want
echo ""
echo "Select build type:"
echo "1. APK"
echo "2. App Bundle (recommended for Google Play Store)"
echo "3. Both"
echo ""
read -p "Enter your choice (1-3): " build_choice

case $build_choice in
    1)
        print_status "Building APK..."
        flutter build apk --release "${MONETIZATION_DART_DEFINES[@]}"
        print_success "APK built successfully!"
        print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    2)
        print_status "Building App Bundle..."
        flutter build appbundle --release "${MONETIZATION_DART_DEFINES[@]}"
        print_success "App Bundle built successfully!"
        print_status "App Bundle location: build/app/outputs/bundle/release/app-release.aab"
        ;;
    3)
        print_status "Building APK..."
        flutter build apk --release "${MONETIZATION_DART_DEFINES[@]}"
        print_success "APK built successfully!"

        print_status "Building App Bundle..."
        flutter build appbundle --release "${MONETIZATION_DART_DEFINES[@]}"
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
