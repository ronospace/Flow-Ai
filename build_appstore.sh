#!/bin/bash

# App Store Build Script for Flow Ai
# This script builds and prepares the app for App Store submission

set -e

echo "🚀 Starting App Store build preparation..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

# Get current version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)
VERSION_NAME=$(echo $VERSION | cut -d'+' -f1)

echo -e "${GREEN}📱 Building Flow Ai${NC}"
echo -e "   Version: ${VERSION_NAME}"
echo -e "   Build Number: ${BUILD_NUMBER}"

# Clean previous builds
echo -e "\n${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Verify iOS dependencies
echo -e "\n${YELLOW}📦 Installing iOS dependencies...${NC}"
cd ios
pod install
cd ..

# Run static analysis
echo -e "\n${YELLOW}🔍 Running static analysis...${NC}"
flutter analyze --no-fatal-infos || {
    echo -e "${RED}⚠️  Analysis found issues. Please review and fix before submitting.${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
}

# Build iOS app for App Store
echo -e "\n${YELLOW}🏗️  Building iOS release for App Store...${NC}"
flutter build ipa \
    --release \
    --export-options-plist=ios/ExportOptionsAppStore.plist \
    --build-number=$BUILD_NUMBER \
    --build-name=$VERSION_NAME

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ Build completed successfully!${NC}"
    echo -e "\n📦 IPA location:"
    echo -e "   build/ios/ipa/flow_ai.ipa"
    echo -e "\n📋 Next steps:"
    echo -e "   1. Open Xcode"
    echo -e "   2. Product > Archive"
    echo -e "   3. Distribute App to App Store Connect"
    echo -e "   4. Submit for review in App Store Connect"
    echo -e "\n${YELLOW}⚠️  Important: Make sure to verify the following before submission:${NC}"
    echo -e "   ✓ HealthKit disclosure banners are visible"
    echo -e "   ✓ Medical citations section is accessible"
    echo -e "   ✓ Privacy descriptions are accurate"
    echo -e "   ✓ All features work correctly"
    echo -e "   ✓ App Store Connect metadata is complete"
else
    echo -e "\n${RED}❌ Build failed. Please check the errors above.${NC}"
    exit 1
fi

