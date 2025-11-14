#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Generating Go protobuf types"
pushd "${ROOT_DIR}/src" >/dev/null
./build-protos.sh
echo "==> Building Android shared libraries"
./build-android.sh "${@}"
echo "==> Building iOS archives"
./build-ios.sh "${@}"
popd >/dev/null

if command -v flutter >/dev/null 2>&1; then
  echo "==> Refreshing Dart bindings via ffigen"
  pushd "${ROOT_DIR}" >/dev/null
  flutter pub get
  dart run ffigen --config ffigen.yaml

  if command -v protoc >/dev/null 2>&1; then
    echo "==> Regenerating Dart protobuf stubs"
    protoc --proto_path=lib/protos --dart_out=lib/protos lib/protos/feed.proto
  else
    echo "Skipping Dart protobuf generation: protoc not found on PATH" >&2
  fi
  popd >/dev/null
else
  echo "Flutter SDK not detected; skipping Dart binding regeneration" >&2
fi

echo "Build pipeline complete."