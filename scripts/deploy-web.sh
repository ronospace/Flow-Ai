#!/bin/bash

# FlowSense Web Deployment Script
# This script builds and deploys the FlowSense web app

set -e  # Exit on any error

echo "🌐 FlowSense Web Deployment"
echo "=========================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

# Build for web
print_status "Building for web (release mode)..."
flutter build web --release

print_success "Web build completed successfully!"

# Check if Firebase CLI is available
if command -v firebase &> /dev/null; then
    print_status "Firebase CLI found. Do you want to deploy to Firebase Hosting? (y/n)"
    read -r deploy_firebase
    
    if [[ $deploy_firebase == "y" || $deploy_firebase == "Y" ]]; then
        print_status "Deploying to Firebase Hosting..."
        firebase deploy --only hosting
        print_success "Deployed to Firebase Hosting successfully!"
    else
        print_status "Skipping Firebase deployment"
    fi
else
    print_status "Firebase CLI not found. Install it with: npm install -g firebase-tools"
fi

print_status "Build artifacts available at: build/web/"

# Provide instructions for manual deployment
echo ""
echo "📋 Manual Deployment Options:"
echo "=============================="
echo "1. Firebase Hosting:"
echo "   - Install Firebase CLI: npm install -g firebase-tools"
echo "   - firebase init hosting"
echo "   - firebase deploy"
echo ""
echo "2. Netlify:"
echo "   - Drag and drop the 'build/web' folder to netlify.com"
echo ""
echo "3. Vercel:"
echo "   - Run: vercel --cwd build/web"
echo ""
echo "4. GitHub Pages:"
echo "   - Push 'build/web' contents to gh-pages branch"

print_success "Web deployment script completed! 🎉"
