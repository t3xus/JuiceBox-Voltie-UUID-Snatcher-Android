#!/bin/bash

# Script to automate building and signing an Android APK for Voltie UUID Snatcher

# Log file for error tracking
LOG_DIR="build_logs"
mkdir -p $LOG_DIR
LOG_FILE="$LOG_DIR/build_$(date +'%Y%m%d_%H%M%S').log"
exec > >(tee -a $LOG_FILE) 2>&1

# Detect the operating system
detect_os() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macOS detected."
        OS="macOS"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case $ID in
            ubuntu)
                echo "Ubuntu detected."
                OS="Ubuntu"
                ;;
            debian)
                echo "Debian detected."
                OS="Debian"
                ;;
            rhel|centos)
                echo "Red Hat or CentOS detected."
                OS="Redhat"
                ;;
            *)
                echo "Unsupported Linux distribution: $ID"
                exit 1
                ;;
        esac
    else
        echo "Unsupported operating system."
        exit 1
    fi
}

detect_os

# Ensure required tools are installed and available
ensure_tool_installed() {
    TOOL_NAME=$1
    INSTALL_CMD=$2

    if ! command -v $TOOL_NAME &> /dev/null; then
        echo "$TOOL_NAME is not installed. Installing..."
        eval $INSTALL_CMD || { echo "Failed to install $TOOL_NAME."; exit 1; }
    else
        echo "$TOOL_NAME is already installed."
    fi
}

# Adjust installation commands based on OS
case $OS in
    macOS)
        ensure_tool_installed "keytool" "brew install openjdk"
        ensure_tool_installed "gradlew" "echo 'Gradle wrapper must be part of the project.'"
        ensure_tool_installed "jarsigner" "brew install openjdk"
        ensure_tool_installed "zipalign" "brew install android-sdk"
        ensure_tool_installed "curl" "brew install curl"
        ensure_tool_installed "unzip" "brew install unzip"
        ;;
    Ubuntu|Debian)
        ensure_tool_installed "keytool" "sudo apt-get install -y openjdk-11-jdk"
        ensure_tool_installed "gradlew" "echo 'Gradle wrapper must be part of the project.'"
        ensure_tool_installed "jarsigner" "sudo apt-get install -y openjdk-11-jdk"
        ensure_tool_installed "zipalign" "sudo apt-get install -y zipalign"
        ensure_tool_installed "curl" "sudo apt-get install -y curl"
        ensure_tool_installed "unzip" "sudo apt-get install -y unzip"
        ;;
    Redhat)
        ensure_tool_installed "keytool" "sudo yum install -y java-11-openjdk"
        ensure_tool_installed "gradlew" "echo 'Gradle wrapper must be part of the project.'"
        ensure_tool_installed "jarsigner" "sudo yum install -y java-11-openjdk"
        ensure_tool_installed "zipalign" "sudo yum install -y zipalign"
        ensure_tool_installed "curl" "sudo yum install -y curl"
        ensure_tool_installed "unzip" "sudo yum install -y unzip"
        ;;
esac

# Add required paths to PATH if necessary
ANDROID_SDK_PATH="$HOME/Android/Sdk"
if [[ ! "$PATH" =~ "$ANDROID_SDK_PATH" ]]; then
    echo "Adding Android SDK tools to PATH."
    export PATH="$ANDROID_SDK_PATH/tools:$ANDROID_SDK_PATH/platform-tools:$PATH"
fi

# Step 1: Ensure Gradle Wrapper
if [ ! -f "./gradlew" ]; then
    echo "Downloading Gradle wrapper..."
    curl -L -o gradle-wrapper.zip https://services.gradle.org/distributions/gradle-7.4-bin.zip || { echo "Failed to download Gradle wrapper."; exit 1; }
    unzip gradle-wrapper.zip -d ./gradle-wrapper && rm gradle-wrapper.zip
    echo "Gradle wrapper downloaded."
fi

# Step 2: Clean the project
echo "Cleaning the project..."
./gradlew clean || { echo "Failed to clean the project."; exit 1; }

# Step 3: Build the APK
interactive_build_type() {
    echo "Choose build type: (release/debug)"
    read BUILD_TYPE
    BUILD_TYPE=${BUILD_TYPE,,}
    if [[ "$BUILD_TYPE" != "release" && "$BUILD_TYPE" != "debug" ]]; then
        echo "Invalid build type. Defaulting to release."
        BUILD_TYPE="release"
    fi
    echo "$BUILD_TYPE"
}
BUILD_TYPE=${1:-$(interactive_build_type)}
./gradlew assemble${BUILD_TYPE^} || { echo "Failed to build the APK."; exit 1; }

# Step 4: Check for the release APK output
APK_PATH="./app/build/outputs/apk/$BUILD_TYPE/app-$BUILD_TYPE.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "Error: APK not found at $APK_PATH"
    exit 1
fi

echo "APK built successfully: $APK_PATH"

# Step 5: Signing the APK
KEYSTORE_PATH="keystore.jks"
ALIAS="voltie"

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "Generating a new keystore..."
    keytool -genkey -v -keystore $KEYSTORE_PATH -keyalg RSA -keysize 2048 -validity 10000 -alias $ALIAS -storepass password -keypass password -dname "CN=Voltie, OU=Engineering, O=VoltieGroup, L=City, S=State, C=US" || { echo "Failed to generate keystore."; exit 1; }
fi

SIGNED_APK="app-$BUILD_TYPE-signed.apk"

echo "Signing the APK..."
jarsigner -verbose -keystore $KEYSTORE_PATH -storepass password -keypass password -signedjar $SIGNED_APK $APK_PATH $ALIAS || { echo "Failed to sign the APK."; exit 1; }

# Step 6: Verify the signed APK
echo "Verifying the signed APK..."
jarsigner -verify -verbose -certs $SIGNED_APK || { echo "Failed to verify the signed APK."; exit 1; }

# Step 7: Align the APK using zipalign
OUTPUT_DIR="output_apks"
mkdir -p $OUTPUT_DIR
ALIGNED_APK="$OUTPUT_DIR/app-$BUILD_TYPE-aligned.apk"

zipalign -v 4 $SIGNED_APK $ALIGNED_APK || { echo "Failed to align the APK."; exit 1; }

# Step 8: Cleanup intermediate files
echo "Cleaning up intermediate files..."
rm -f $SIGNED_APK

# Output final APK path
echo "APK built, signed, and aligned successfully: $ALIGNED_APK"

# Step 9: Log and notify
if [ $? -eq 0 ]; then
    echo "Build process completed successfully. Logs saved to $LOG_FILE."
else
    echo "Build process encountered errors. Check $LOG_FILE for details."
fi

# Step 10: Email notification
if command -v mail &> /dev/null; then
    echo "Sending email notification..."
    echo "Build completed. Logs attached." | mail -s "Build Notification" -A $LOG_FILE user@example.com
else
    echo "mail command not available. Skipping email notification."
fi
