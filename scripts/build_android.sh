#!/bin/bash

# Android APK Build Script for Vela
# This script builds a release APK for Android

set -e

echo "🤖 Starting Android APK build for Vela..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Please run this script from the project root.${NC}"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build for Android
echo "📱 Building Android APK..."
flutter build apk --release

echo -e "${GREEN}✅ APK build completed successfully!${NC}"
echo ""
echo -e "${BLUE}📱 APK file location:${NC}"
echo "build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Test the APK on an Android device"
echo "2. Share the APK file with testers"
echo "3. Upload to Google Play Console if needed"
echo ""
echo -e "${GREEN}✅ Your APK is ready at: build/app/outputs/flutter-apk/app-release.apk${NC}"

# Show file size
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    FILE_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
    echo -e "${BLUE}📦 APK file size: $FILE_SIZE${NC}"
fi 