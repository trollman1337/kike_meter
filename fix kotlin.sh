#!/bin/bash

# Define the path to your build.gradle file
BUILD_GRADLE_PATH="android/app/build.gradle"

# Define the minSdkVersion you want to set
MIN_SDK_VERSION=21

# Check if minSdkVersion is already set in build.gradle
if grep -q "minSdkVersion" "$BUILD_GRADLE_PATH"; then
  echo "minSdkVersion already set in build.gradle"
else
  echo "minSdkVersion not found in build.gradle. Adding it..."
  sed -i '' "/defaultConfig {/a\\
      minSdkVersion $MIN_SDK_VERSION
  " $BUILD_GRADLE_PATH
  echo "minSdkVersion set to $MIN_SDK_VERSION in build.gradle"
fi

# Optional: Update local.properties with minSdkVersion
LOCAL_PROPERTIES_PATH="android/local.properties"
if grep -q "flutter.minSdkVersion" "$LOCAL_PROPERTIES_PATH"; then
  echo "flutter.minSdkVersion already set in local.properties"
else
  echo "flutter.minSdkVersion not found in local.properties. Adding it..."
  echo "flutter.minSdkVersion=$MIN_SDK_VERSION" >> $LOCAL_PROPERTIES_PATH
  echo "flutter.minSdkVersion set to $MIN_SDK_VERSION in local.properties"
fi

# Run flutter_launcher_icons to generate the icons
echo "Generating launcher icons..."
flutter pub run flutter_launcher_icons:main

# Check if the launcher icons were successfully generated
if [ $? -eq 0 ]; then
  echo "Launcher icons generated successfully!"
else
  echo "Failed to generate launcher icons."
fi
