#!/usr/bin/env bash
# Build libwebp from source without Homebrew targeting macOS 15.0+
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STAGE="$REPO_ROOT/lib/webp"
BUILD_DIR="$REPO_ROOT/lib/.webp-build"
SRC_DIR="$REPO_ROOT/lib/webp-src"

if [ -f "$STAGE/lib/libwebp.dylib" ] && [ -f "$STAGE/include/webp/decode.h" ]; then
    echo "[build-webp] lib/webp already built — nothing to do"
    exit 0
fi

echo "[build-webp] cloning libwebp..."
rm -rf "$SRC_DIR" "$BUILD_DIR"
git clone --depth 1 https://chromium.googlesource.com/webm/libwebp "$SRC_DIR"

echo "[build-webp] compiling libwebp for macOS 15.0..."
cmake -S "$SRC_DIR" -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX="$STAGE"

cmake --build "$BUILD_DIR" -j "$(sysctl -n hw.ncpu)"
cmake --install "$BUILD_DIR"

rm -rf "$SRC_DIR" "$BUILD_DIR"
echo "[build-webp] staged libwebp at $STAGE"
