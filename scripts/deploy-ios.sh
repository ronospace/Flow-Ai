#!/bin/bash

# FlowSense iOS Deployment Script
# This script builds the iOS app for App Store distribution

set -e  # Exit on any error

echo "📱 FlowSense iOS Deployment"
echo "============================"

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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "iOS deployment requires macOS"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
print_status "Checking Flutter version..."
flutter --version

# Check Xcode version
print_status "Checking Xcode version..."
xcodebuild -version

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

# Check iOS configuration
print_status "Checking iOS configuration..."

# Check if iOS project exists
if [ ! -d "ios" ]; then
    print_error "iOS project directory not found. Run 'flutter create . --platform ios' to add iOS support."
    exit 1
fi

# Check Bundle Identifier
BUNDLE_ID=$(grep -A 1 "CFBundleIdentifier" ios/Runner/Info.plist | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
if [[ $BUNDLE_ID == *"example"* ]]; then
    print_warning "Bundle Identifier contains 'example': $BUNDLE_ID"
    print_warning "Please update Bundle Identifier in ios/Runner/Info.plist and Xcode project"
fi

print_status "Bundle Identifier: $BUNDLE_ID"

# Ask user what type of build they want
echo ""
echo "Select build type:"
echo "1. iOS App (for device testing)"
echo "2. iOS Archive (for App Store distribution)"
echo "3. Open in Xcode (for manual configuration and archiving)"
echo ""
read -p "Enter your choice (1-3): " build_choice

case $build_choice in
    1)
        print_status "Building iOS app for device testing..."
        flutter build ios --release --no-codesign
        print_success "iOS app built successfully!"
        print_status "App location: build/ios/iphoneos/Runner.app"
        ;;
    2)
        print_status "Building iOS Archive (IPA)..."
        if flutter build ipa; then
            print_success "iOS Archive built successfully!"
            print_status "IPA location: build/ios/ipa/FlowSense.ipa"
        else
            print_warning "IPA build failed. This might be due to signing configuration."
            print_status "Building without codesign instead..."
            flutter build ios --release --no-codesign
            print_success "iOS app built successfully!"
            print_status "You'll need to sign and archive manually in Xcode"
        fi
        ;;
    3)
        print_status "Building iOS project..."
        flutter build ios --release --no-codesign
        print_success "iOS project built successfully!"
        
        print_status "Opening Xcode project..."
        open ios/Runner.xcworkspace
        
        echo ""
        echo "📋 Manual Steps in Xcode:"
        echo "========================="
        echo "1. Select 'Runner' project in navigator"
        echo "2. Select 'Runner' target"
        echo "3. Set up Signing & Capabilities:"
        echo "   - Select your Development Team"
        echo "   - Ensure Bundle Identifier is unique"
        echo "4. Archive the project:"
        echo "   - Product → Archive"
        echo "   - Wait for archive to complete"
        echo "5. Upload to App Store:"
        echo "   - Click 'Distribute App'"
        echo "   - Select 'App Store Connect'"
        echo "   - Follow the upload wizard"
        echo ""
        print_success "Xcode opened. Follow the manual steps above."
        exit 0
        ;;
    *)
        print_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Provide next steps
echo ""
echo "📋 Next Steps for App Store:"
echo "============================"
echo "1. Go to App Store Connect (appstoreconnect.apple.com)"
echo "2. Create a new app or select existing app"
echo "3. Fill out app information:"
echo "   - App name and description"
echo "   - Keywords and category"
echo "   - Screenshots for all device sizes"
echo "   - App preview videos (optional)"
echo "4. Set up app pricing and availability"
echo "5. Configure App Store Review Information"
echo "6. Submit for review"
echo ""
echo "📝 Required Assets:"
echo "- App Icon (1024x1024px for App Store)"
echo "- Screenshots for iPhone and iPad"
echo "- App description and keywords"
echo "- Privacy Policy URL"
echo ""

print_success "iOS deployment script completed! 🎉"
