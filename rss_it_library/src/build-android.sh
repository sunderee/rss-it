#!/usr/bin/env bash
set -euo pipefail

# Library configuration
PROJECT_NAME="gofeed_flutter"
LIB_NAME="lib${PROJECT_NAME}"
PREBUILD_PATH="../prebuild/Android"

# Build mode configuration
BUILD_MODE="${1:-release}"
GO_BUILD_FLAGS="-trimpath -ldflags=-s"

# Detect OS for NDK path
NDK_VERSION="27.0.12077973"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  ANDROID_HOME="${HOME}/Android/Sdk"
  NDK_PLATFORM="linux-x86_64"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  ANDROID_HOME="${HOME}/Library/Android/sdk"
  NDK_PLATFORM="darwin-x86_64"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  ANDROID_HOME="${LOCALAPPDATA//\\//}/Android/Sdk"
  NDK_PLATFORM="windows-x86_64"
else
  echo "Unsupported operating system: $OSTYPE"
  exit 1
fi

# Check if NDK exists
NDK_BIN="${ANDROID_HOME}/ndk/${NDK_VERSION}/toolchains/llvm/prebuilt/${NDK_PLATFORM}/bin"
if [ ! -d "$NDK_BIN" ]; then
  echo "Error: Android NDK not found at ${NDK_BIN}"
  echo "Please install Android NDK ${NDK_VERSION} or update the script with your NDK path"
  exit 1
fi

echo "Using Android NDK at: ${NDK_BIN}"
echo "Building ${PROJECT_NAME} for Android..."

# Function to build for a specific architecture
build_for_arch() {
  local arch="$1"
  local goarch="$2"
  local cc="$3"
  local dir_name="$4"
  local goarm="${5:-}"
  
  echo "Building for ${arch}..."
  
  # Create output directory
  mkdir -p "${PREBUILD_PATH}/${dir_name}"
  
  # Set environment variables
  export CGO_ENABLED=1
  export GOOS=android
  export GOARCH="$goarch"
  [ -n "$goarm" ] && export GOARM="$goarm"
  export CC="${NDK_BIN}/${cc}"
  
  # Build the library
  go build $GO_BUILD_FLAGS -buildmode=c-shared \
    -o "${PREBUILD_PATH}/${dir_name}/${LIB_NAME}.so" .
  
  # Remove header file
  rm -f "${PREBUILD_PATH}/${dir_name}/${LIB_NAME}.h"
  
  echo "Successfully built for ${arch}"
}

# Build for all architectures
build_for_arch "ARMv7" "arm" "armv7a-linux-androideabi21-clang" "armeabi-v7a" "7"
build_for_arch "ARM64" "arm64" "aarch64-linux-android21-clang" "arm64-v8a"
build_for_arch "x86" "386" "i686-linux-android21-clang" "x86"
build_for_arch "x86_64" "amd64" "x86_64-linux-android21-clang" "x86_64"

echo "Android build complete. Libraries are in ${PREBUILD_PATH}" 