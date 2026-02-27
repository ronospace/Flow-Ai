#!/bin/bash

echo "Removing all CocoaPods repos..."
rm -rf ~/.cocoapods/repos

echo "Setting up CocoaPods..."
pod setup

echo "Cleaning iOS build folders..."
cd ios || exit
rm -rf Pods Podfile.lock

echo "Fixing Podfile sources..."
sed -i '' '/^source/d' Podfile
sed -i '' '1s/^/source "https:\/\/cdn.cocoapods.org\/"\n/' Podfile

echo "Installing pods with repo update..."
pod install --repo-update

echo "Returning to project root..."
cd ..

echo "Done! Now run: flutter run"

