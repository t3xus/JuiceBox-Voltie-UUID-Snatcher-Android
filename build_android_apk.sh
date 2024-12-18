#!/bin/bash

# Script to automate building and signing an Android APK for Voltie UUID Snatcher

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
        ;;
    Ubuntu|Debian)
        ensure_tool_installed "keytool" "sudo apt-get install -y openjdk-11-jdk"
        ensure_tool_installed "gradlew" "echo 'Gradle wrapper must be part of the project.'"
        ensure_tool_installed "jarsigner" "sudo apt-get install -y openjdk-11-jdk"
        ensure_tool_installed "zipalign" "sudo apt-get install -y zipalign"
        ;;
    Redhat)
        ensure_tool_installed "keytool" "sudo yum install -y java-11-openjdk"
        ensure_tool_installed "gradlew" "echo 'Gradle wrapper must be part of the project.'"
        ensure_tool_installed "jarsigner" "sudo yum install -y java-11-openjdk"
        ensure_tool_installed "zipalign" "sudo yum install -y zipalign"
        ;;
esac

# Add required paths to PATH if necessary
ANDROID_SDK_PATH="$HOME/Android/Sdk"
if [[ ! "$PATH" =~ "$ANDROID_SDK_PATH" ]]; then
    echo "Adding Android SDK tools to PATH."
    export PATH="$ANDROID_SDK_PATH/tools:$ANDROID_SDK_PATH/platform-tools:$PATH"
fi

# Step 1: Clean the project
echo "Cleaning the project..."
./gradlew clean || { echo "Failed to clean the project."; exit 1; }

# Step 2: Build the APK
echo "Building the APK..."
./gradlew assembleRelease || { echo "Failed to build the APK."; exit 1; }

# Step 3: Check for the release APK output
APK_PATH="./app/build/outputs/apk/release/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
    echo "Error: Release APK not found at $APK_PATH"
    exit 1
fi

echo "APK built successfully: $APK_PATH"

# Step 4: Signing the APK
KEYSTORE_PATH="keystore.jks"
ALIAS="voltie"

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "Generating a new keystore..."
    keytool -genkey -v -keystore $KEYSTORE_PATH -keyalg RSA -keysize 2048 -validity 10000 -alias $ALIAS -storepass password -keypass password -dname "CN=Voltie, OU=Engineering, O=VoltieGroup, L=City, S=State, C=US" || { echo "Failed to generate keystore."; exit 1; }
fi

SIGNED_APK="app-release-signed.apk"

echo "Signing the APK..."
jarsigner -verbose -keystore $KEYSTORE_PATH -storepass password -keypass password -signedjar $SIGNED_APK $APK_PATH $ALIAS || { echo "Failed to sign the APK."; exit 1; }

# Step 5: Verify the signed APK
echo "Verifying the signed APK..."
jarsigner -verify -verbose -certs $SIGNED_APK || { echo "Failed to verify the signed APK."; exit 1; }

# Step 6: Align the APK using zipalign
ALIGNED_APK="app-release-aligned.apk"

zipalign -v 4 $SIGNED_APK $ALIGNED_APK || { echo "Failed to align the APK."; exit 1; }

# Step 7: Cleanup intermediate files
echo "Cleaning up intermediate files..."
rm -f $SIGNED_APK

# Output final APK path
echo "APK built, signed, and aligned successfully: $ALIGNED_APK"
