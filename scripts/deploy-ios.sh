#!/bin/bash

# Flow AI iOS App Store Deployment Script
# This script delegates iOS release builds to the signed App Store IPA builder.

set -euo pipefail

echo "📱 Flow AI iOS App Store Deployment"
echo "==================================="

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "iOS deployment requires macOS"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed or not in PATH"
    exit 1
fi

if [ ! -x "./build_appstore.sh" ]; then
    print_error "build_appstore.sh is missing or not executable"
    exit 1
fi

print_status "Building signed App Store IPA through build_appstore.sh"
./build_appstore.sh

print_success "iOS App Store build completed"
