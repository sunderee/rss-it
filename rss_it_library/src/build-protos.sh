#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTO_DIR="${SCRIPT_DIR}/proto"

if ! command -v protoc >/dev/null 2>&1; then
  echo "Error: protoc not found on PATH. Install the protobuf compiler first." >&2
  exit 1
fi

pushd "${PROTO_DIR}" >/dev/null
PATH="$(go env GOPATH)/bin:${PATH}" protoc --go_out=. --go_opt=paths=source_relative feed.proto
popd >/dev/null