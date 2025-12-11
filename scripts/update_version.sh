#!/bin/bash

# Version Update Script for TestFlight
# Usage: ./scripts/update_version.sh [major|minor|patch|build]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: pubspec.yaml not found. Please run this script from the project root.${NC}"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
echo -e "${BLUE}📱 Current version: $CURRENT_VERSION${NC}"

# Parse current version
IFS='+' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
VERSION_NUMBER="${VERSION_PARTS[0]}"
BUILD_NUMBER="${VERSION_PARTS[1]}"

IFS='.' read -ra VERSION_COMPONENTS <<< "$VERSION_NUMBER"
MAJOR="${VERSION_COMPONENTS[0]}"
MINOR="${VERSION_COMPONENTS[1]}"
PATCH="${VERSION_COMPONENTS[2]}"

# Function to update version
update_version() {
    local update_type=$1
    
    case $update_type in
        "major")
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            BUILD_NUMBER=$((BUILD_NUMBER + 1))
            ;;
        "minor")
            MINOR=$((MINOR + 1))
            PATCH=0
            BUILD_NUMBER=$((BUILD_NUMBER + 1))
            ;;
        "patch")
            PATCH=$((PATCH + 1))
            BUILD_NUMBER=$((BUILD_NUMBER + 1))
            ;;
        "build")
            BUILD_NUMBER=$((BUILD_NUMBER + 1))
            ;;
        *)
            echo -e "${RED}❌ Error: Invalid update type. Use: major, minor, patch, or build${NC}"
            echo "Usage: $0 [major|minor|patch|build]"
            exit 1
            ;;
    esac
    
    NEW_VERSION="$MAJOR.$MINOR.$PATCH+$BUILD_NUMBER"
    
    # Update pubspec.yaml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml
    else
        # Linux
        sed -i "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml
    fi
    
    echo -e "${GREEN}✅ Version updated to: $NEW_VERSION${NC}"
    echo -e "${YELLOW}📝 Don't forget to commit this change!${NC}"
}

# Check if update type is provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No update type specified. Updating build number...${NC}"
    update_version "build"
else
    update_version "$1"
fi

echo ""
echo -e "${BLUE}📋 Version update complete!${NC}"
echo "Next steps:"
echo "1. Test the app to ensure everything works"
echo "2. Commit the version change: git add pubspec.yaml && git commit -m 'Bump version to $NEW_VERSION'"
echo "3. Run: ./scripts/validate_deployment.sh"
echo "4. Run: ./scripts/deploy_testflight.sh" 