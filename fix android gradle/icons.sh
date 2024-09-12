#!/bin/bash

# Variables
KOTLIN_VERSION="1.8.0"
PROJECT_ROOT="$(pwd)"

# Update Kotlin version in build.gradle (Project Level)
echo "Updating Kotlin version in build.gradle (Project Level)..."
sed -i "" "s/ext.kotlin_version = '.*'/ext.kotlin_version = '$KOTLIN_VERSION'/g" "$PROJECT_ROOT/build.gradle"

# Update Kotlin version in build.gradle (App Level)
echo "Updating Kotlin version in build.gradle (App Level)..."
sed -i "" "s/id 'org.jetbrains.kotlin.android' version '.*'/id 'org.jetbrains.kotlin.android' version '$KOTLIN_VERSION'/g" "$PROJECT_ROOT/app/build.gradle"

# Clean and rebuild the project
echo "Cleaning and rebuilding the project..."
./gradlew clean
./gradlew build

# Optional: Invalidate caches/restart (if using Android Studio)
# Uncomment the following line if using Android Studio and want to automate cache invalidation
# echo "Invalidating caches and restarting Android Studio..."
# idea --invalidate-caches

echo "Kotlin version update and project rebuild completed."
