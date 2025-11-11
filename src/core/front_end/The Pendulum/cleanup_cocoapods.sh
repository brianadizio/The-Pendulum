#!/bin/bash

# Navigate to project directory
cd "$(dirname "$0")"

# Install CocoaPods if not already installed
if ! command -v pod &> /dev/null; then
    echo "CocoaPods is not installed. Installing CocoaPods..."
    sudo gem install cocoapods
fi

# Run pod install to update the sandbox
echo "Running pod install to update the sandbox..."
pod install

# Deintegrate CocoaPods from the project
echo "Deintegrating CocoaPods from the project..."
pod deintegrate

# Clean up CocoaPods files
echo "Cleaning up CocoaPods files..."
rm -rf Pods
rm -f Podfile.lock
rm -f .podinstall.lock
rm -f Podfile

# Close Xcode workspace if open
echo "Please close Xcode if it's open."
read -p "Press Enter when Xcode is closed..."

# Remove workspace
if [ -d "The Pendulum.xcworkspace" ]; then
    echo "Removing workspace..."
    rm -rf "The Pendulum.xcworkspace"
fi

echo ""
echo "CocoaPods cleanup complete. You can now open the .xcodeproj file directly."
echo "NOTE: If you were opening the .xcworkspace before, you should now use the .xcodeproj file instead."
echo ""
echo "To use our custom chart implementation, make sure these files are included in your project:"
echo "- SimpleCharts.swift"
echo "- AnalyticsDashboardViewNative.swift"
echo ""