#!/bin/bash

# Define paths
BASE_PATH="/Users/razor50333/Desktop/dev/kike_meter"    # Update this to your project base path
OUTPUT_DIR="${BASE_PATH}/binaries"  # Directory where binaries will be copied

# Create the output directory if it does not exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/web" # Create a subdirectory for web builds

# Function to build Flutter for iOS
build_ios() {
    echo "Building iOS app..."
    cd "$BASE_PATH/ios"
    flutter build ios --release
    cp -r "$BASE_PATH/build/ios/iphoneos/Runner.app" "$OUTPUT_DIR"
    echo "iOS build completed and copied to $OUTPUT_DIR"
}

# Function to build Flutter for Android (APK)
build_android() {
    echo "Building Android app..."
    cd "$BASE_PATH"
    flutter build apk --release
    cp "$BASE_PATH/build/app/outputs/flutter-apk/app-release.apk" "$OUTPUT_DIR"
    echo "Android APK build completed and copied to $OUTPUT_DIR"
}

# Function to build Flutter for Web
build_web() {
    echo "Building Web app..."
    cd "$BASE_PATH"
    flutter build web --release
    cp -r "$BASE_PATH/build/web" "$OUTPUT_DIR/web"
    echo "Web build completed and copied to $OUTPUT_DIR/web"
}

# Function to build Flutter for Linux
build_linux() {
    echo "Building Linux app..."
    cd "$BASE_PATH"
    flutter build linux --release
    cp "$BASE_PATH/build/linux/x64/release/bundle/your_app" "$OUTPUT_DIR"
    echo "Linux build completed and copied to $OUTPUT_DIR"
}

# Function to build Flutter for Windows (EXE)
build_windows() {
    echo "Building Windows app..."
    cd "$BASE_PATH"
    flutter build windows --release
    cp "$BASE_PATH/build/windows/runner/Release/your_app.exe" "$OUTPUT_DIR"
    echo "Windows EXE build completed and copied to $OUTPUT_DIR"
}

# Function to build Flutter for macOS
build_macos() {
    echo "Building macOS app..."
    cd "$BASE_PATH"
    flutter build macos --release
    cp -r "$BASE_PATH/build/macos/Build/Products/Release/your_app.app" "$OUTPUT_DIR"
    echo "macOS build completed and copied to $OUTPUT_DIR"
}

# Main script execution
echo "Starting build process..."

# Run the build functions
build_ios
build_android
build_web
build_linux
build_windows
build_macos

echo "All builds completed and binaries are copied to $OUTPUT_DIR"
