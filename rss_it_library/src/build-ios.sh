#!/usr/bin/env bash
set -euo pipefail

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "Error: This script must be run on macOS"
  exit 1
fi

# Library configuration
PROJECT_NAME="rss_it_library"
LIB_NAME="lib${PROJECT_NAME}"
PREBUILD_PATH="../prebuild/iOS"

# Build mode configuration
BUILD_MODE="${1:-release}"
GO_BUILD_FLAGS="-trimpath -ldflags=-s"

# Check for Xcode tools
if ! command -v xcrun &> /dev/null; then
  echo "Error: Xcode command line tools not found"
  echo "Please install Xcode command line tools with: xcode-select --install"
  exit 1
fi

echo "Building ${PROJECT_NAME} for iOS..."

# Minimum iOS version
MIN_IOS_VERSION="11.0"

# Function to build for a specific architecture
build_for_arch() {
  local sdk="$1"
  local goarch="$2"
  local carch="$3"
  local device_type="$4"
  
  echo "Building for ${device_type} (${carch})..."
  
  # Create output directory
  mkdir -p "${PREBUILD_PATH}/${sdk}/${carch}"
  
  # Get SDK path
  SDK_PATH=$(xcrun --sdk "${sdk}" --show-sdk-path)
  
  # Set target triple
  if [ "$sdk" = "iphoneos" ]; then
    TARGET="${carch}-apple-ios${MIN_IOS_VERSION}"
  else
    TARGET="${carch}-apple-ios${MIN_IOS_VERSION}-simulator"
  fi
  
  # Find Clang compiler
  CLANG=$(xcrun --sdk "${sdk}" --find clang)
  
  # Set environment variables
  export GOOS=ios
  export CGO_ENABLED=1
  export GOARCH="${goarch}"
  export CC="${CLANG} -target ${TARGET} -isysroot ${SDK_PATH}"
  
  # Build the library
  go build ${GO_BUILD_FLAGS} -buildmode=c-archive \
    -o "${PREBUILD_PATH}/${sdk}/${carch}/${LIB_NAME}.a" .
  
  # Remove header file
  rm -f "${PREBUILD_PATH}/${sdk}/${carch}/${LIB_NAME}.h"
  
  echo "Successfully built for ${device_type} (${carch})"
}

# Build for each platform
build_for_arch "iphonesimulator" "amd64" "x86_64" "iOS Simulator"
build_for_arch "iphonesimulator" "arm64" "arm64" "iOS Simulator (Apple Silicon)"
build_for_arch "iphoneos" "arm64" "arm64" "iOS Device"

echo "iOS build complete. Libraries are in ${PREBUILD_PATH}"

# Ask if user wants to create a universal library
read -p "Create universal library for simulators? (y/n): " create_universal
if [[ "${create_universal}" == "y" ]]; then
  echo "Creating universal library for simulators..."
  
  # Create universal directory
  UNIVERSAL_DIR="${PREBUILD_PATH}/iphonesimulator/universal"
  mkdir -p "${UNIVERSAL_DIR}"
  
  # Create universal binary
  lipo -create \
    "${PREBUILD_PATH}/iphonesimulator/x86_64/${LIB_NAME}.a" \
    "${PREBUILD_PATH}/iphonesimulator/arm64/${LIB_NAME}.a" \
    -output "${UNIVERSAL_DIR}/${LIB_NAME}.a"
  
  echo "Universal library created at: ${UNIVERSAL_DIR}/${LIB_NAME}.a"
fi 