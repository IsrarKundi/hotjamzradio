#!/bin/bash

# iOS Configuration Verification Script
# This script checks if all iOS configurations are properly set

echo "🔍 Hot Jamz Radio - iOS Configuration Verification"
echo "=================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

IOS_DIR="ios"
SUCCESS_COUNT=0
FAIL_COUNT=0

# Check 1: iOS Deployment Target
echo "1️⃣  Checking iOS Deployment Target..."
if grep -q "IPHONEOS_DEPLOYMENT_TARGET = 13.0;" "$IOS_DIR/Runner.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✅ iOS deployment target is 13.0 or higher${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}❌ iOS deployment target needs to be updated to 13.0${NC}"
    ((FAIL_COUNT++))
fi
echo ""

# Check 2: UIDeviceFamily in Info.plist
echo "2️⃣  Checking iPad Support (UIDeviceFamily)..."
if grep -q "UIDeviceFamily" "$IOS_DIR/Runner/Info.plist"; then
    echo -e "${GREEN}✅ UIDeviceFamily is configured for iPhone and iPad${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}❌ UIDeviceFamily is missing - iPad support not explicit${NC}"
    ((FAIL_COUNT++))
fi
echo ""

# Check 3: Podfile exists
echo "3️⃣  Checking Podfile..."
if [ -f "$IOS_DIR/Podfile" ]; then
    echo -e "${GREEN}✅ Podfile exists${NC}"
    ((SUCCESS_COUNT++))
    
    # Check platform version in Podfile
    if grep -q "platform :ios, '13.0'" "$IOS_DIR/Podfile"; then
        echo -e "${GREEN}✅ Podfile has correct platform version (13.0)${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${YELLOW}⚠️  Podfile platform version might need updating${NC}"
    fi
else
    echo -e "${RED}❌ Podfile is missing${NC}"
    ((FAIL_COUNT++))
fi
echo ""

# Check 4: Scene Manifest
echo "4️⃣  Checking Scene Manifest for iPad..."
if grep -q "UIApplicationSceneManifest" "$IOS_DIR/Runner/Info.plist"; then
    echo -e "${GREEN}✅ Scene manifest is configured${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}❌ Scene manifest is missing${NC}"
    ((FAIL_COUNT++))
fi
echo ""

# Check 5: LaunchScreen.storyboard
echo "5️⃣  Checking LaunchScreen.storyboard..."
if [ -f "$IOS_DIR/Runner/Base.lproj/LaunchScreen.storyboard" ]; then
    echo -e "${GREEN}✅ LaunchScreen.storyboard exists${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}❌ LaunchScreen.storyboard is missing${NC}"
    ((FAIL_COUNT++))
fi
echo ""

# Check 6: GoogleService-Info.plist
echo "6️⃣  Checking Firebase Configuration..."
if [ -f "$IOS_DIR/Runner/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✅ GoogleService-Info.plist exists${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}❌ GoogleService-Info.plist is missing${NC}"
    ((FAIL_COUNT++))
fi
echo ""

# Check 7: Orientation Support
echo "7️⃣  Checking iPad Orientation Support..."
if grep -q "UISupportedInterfaceOrientations~ipad" "$IOS_DIR/Runner/Info.plist"; then
    echo -e "${GREEN}✅ iPad orientations are configured${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}❌ iPad orientations not configured${NC}"
    ((FAIL_COUNT++))
fi
echo ""

# Check 8: Error Handling in main.dart
echo "8️⃣  Checking Error Handling in main.dart..."
if grep -q "firebaseInitialized = true" "lib/main.dart"; then
    echo -e "${GREEN}✅ Enhanced error handling implemented${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${YELLOW}⚠️  Basic error handling present${NC}"
fi
echo ""

# Check 9: App Transport Security
echo "9️⃣  Checking App Transport Security..."
if grep -q "NSAppTransportSecurity" "$IOS_DIR/Runner/Info.plist"; then
    echo -e "${GREEN}✅ App Transport Security is configured${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${YELLOW}⚠️  App Transport Security not found${NC}"
fi
echo ""

# Summary
echo "=================================================="
echo "📊 Summary:"
echo -e "${GREEN}✅ Passed: $SUCCESS_COUNT${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}❌ Failed: $FAIL_COUNT${NC}"
else
    echo -e "${GREEN}❌ Failed: $FAIL_COUNT${NC}"
fi
echo "=================================================="
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 All iOS configurations are properly set!${NC}"
    echo -e "${GREEN}You can now build and deploy to App Store.${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some configurations need attention.${NC}"
    echo -e "${YELLOW}Please fix the issues above before deploying.${NC}"
    exit 1
fi
