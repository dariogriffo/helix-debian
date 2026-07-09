#!/bin/bash
set -euo pipefail

# Upstream Linux architectures for helix (https://github.com/helix-editor/helix):
#   amd64  -> helix-<version>-x86_64-linux.tar.xz
#   arm64  -> helix-<version>-aarch64-linux.tar.xz
#
# amd64 and arm64 only (upstream also publishes a source tarball; other architectures would need a from-source build).
# TODO: implement helix build

helix_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$helix_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <helix_version> <build_version> [architecture]"
    echo "Example: $0 1.2.3 1 arm64"
    echo "Example: $0 1.2.3 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

echo "build_debian.sh for helix is not implemented yet."
exit 1
