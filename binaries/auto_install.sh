#!/bin/bash

# Define paths
BASE_PATH="/Users/razor50333/Desktop/dev/kike_meter"    # Update this to your project base path
OUTPUT_DIR="${BASE_PATH}/binaries"  # Directory where binaries are stored

# Function to install iOS app
install_ios() {
    echo "Installing iOS app..."
    # Note: iOS apps need to be installed using Xcode or via TestFlight, 
    # this script will just print the path to the app directory
    echo "Locate your iOS app at: $OUTPUT_DIR"
}

# Function to install Android APK
install_android() {
    echo "Installing Android APK..."
    if [ -z "$(which adb)" ]; then
        echo "ADB not found. Please install Android SDK platform-tools."
        exit 1
    fi
    adb install -r "$OUTPUT_DIR/app-release.apk"
    echo "Android APK installed."
}

# Function to handle user input and installation
install_binaries() {
    echo "Select the platform(s) to install:"
    echo "1) iOS"
    echo "2) Android"
    echo "3) All"
    read -p "Enter your choice (1-3): " choice

    case $choice in
        1)
            install_ios
            ;;
        2)
            install_android
            ;;
        3)
            install_ios
            install_android
            ;;
        *)
            echo "Invalid choice. Please select a number between 1 and 3."
            ;;
    esac
}

# Main script execution
echo "Starting installation process..."
install_binaries
echo "Installation process completed."
