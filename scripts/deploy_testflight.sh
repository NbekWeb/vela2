#!/bin/bash

# TestFlight Deployment Script for Vela
# This script works without Apple IDs - you'll need to manually upload to App Store Connect

set -e

echo "🚀 Starting TestFlight deployment for Vela..."

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

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: Xcode is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build for iOS
echo "📱 Building iOS app..."
flutter build ios --release --no-codesign

# Navigate to iOS directory
cd ios

# Archive the app
echo "📦 Archiving app..."
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -destination "generic/platform=iOS" \
           -archivePath build/Runner.xcarchive \
           clean archive

# Export the archive
echo "📤 Exporting archive..."
xcodebuild -exportArchive \
           -archivePath build/Runner.xcarchive \
           -exportPath build/ios \
           -exportOptionsPlist exportOptions.plist

echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Manual Upload Instructions:${NC}"
echo "1. Open Xcode"
echo "2. Go to Window > Organizer"
echo "3. Select your app"
echo "4. Click 'Distribute App'"
echo "5. Choose 'App Store Connect'"
echo "6. Select 'Upload'"
echo "7. Choose the .ipa file from: $(pwd)/build/ios/Runner.ipa"
echo "8. Follow the signing and upload process"
echo ""
echo -e "${YELLOW}📱 Alternative: Use Transporter app${NC}"
echo "1. Download Transporter from Mac App Store"
echo "2. Open Transporter"
echo "3. Drag and drop the .ipa file: $(pwd)/build/ios/Runner.ipa"
echo "4. Sign in with your Apple ID"
echo "5. Click 'Deliver'"
echo ""
echo -e "${GREEN}✅ Your .ipa file is ready at: $(pwd)/build/ios/Runner.ipa${NC}"

cd .. 