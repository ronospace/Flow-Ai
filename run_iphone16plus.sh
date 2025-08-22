#!/bin/bash

# FlowSense iPhone 16 Plus Runner Script
# This script always runs the app on iPhone 16 Plus simulator

DEVICE_ID="4AE9785A-6AA6-47F4-8DB1-6C6F84DA1B09"
PROJECT_DIR="/Users/ronos/development/FlowSense"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 FlowSense - iPhone 16 Plus Runner${NC}"
echo -e "${YELLOW}📱 Target Device: iPhone 16 Plus (iOS Simulator)${NC}"
echo -e "${GREEN}📍 Project: $PROJECT_DIR${NC}"
echo ""

# Change to project directory
cd "$PROJECT_DIR" || exit 1

# Check if device is available
echo -e "${BLUE}🔍 Checking device availability...${NC}"
if flutter devices | grep -q "$DEVICE_ID"; then
    echo -e "${GREEN}✅ iPhone 16 Plus simulator is available${NC}"
else
    echo -e "${YELLOW}⚠️  iPhone 16 Plus simulator not found, showing available devices:${NC}"
    flutter devices
    exit 1
fi

echo ""
echo -e "${BLUE}🏗️  Building and running FlowSense on iPhone 16 Plus...${NC}"
echo ""

# Run the app with the specified device
flutter run --debug -d "$DEVICE_ID" "$@"
