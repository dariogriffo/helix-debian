#!/bin/bash
set -euo pipefail

# Upstream Linux architectures for helix (https://github.com/helix-editor/helix):
#   amd64  -> helix-<version>-x86_64-linux.tar.xz
#   arm64  -> helix-<version>-aarch64-linux.tar.xz
#
# amd64 and arm64 only (upstream also publishes a source tarball; other architectures would need a from-source build).

helix_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$helix_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <helix_version> <build_version> [architecture]"
    echo "Example: $0 25.07.1 1 arm64"
    echo "Example: $0 25.07.1 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Function to map Ubuntu architecture to helix release name
get_helix_release() {
    local arch=$1
    case "$arch" in
        "amd64")
            echo "helix-${helix_VERSION}-x86_64-linux"
            ;;
        "arm64")
            echo "helix-${helix_VERSION}-aarch64-linux"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local helix_release

    helix_release=$(get_helix_release "$build_arch")
    if [ -z "$helix_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $helix_release"

    # Clean up any previous builds for this architecture
    rm -rf "$helix_release" || true
    rm -f "${helix_release}.tar.xz" || true

    # Download and extract helix release for this architecture
    if ! wget "https://github.com/helix-editor/helix/releases/download/${helix_VERSION}/${helix_release}.tar.xz"; then
        echo "❌ Failed to download helix release for $build_arch"
        return 1
    fi

    if ! tar -xf "${helix_release}.tar.xz"; then
        echo "❌ Failed to extract helix release for $build_arch"
        return 1
    fi

    rm -f "${helix_release}.tar.xz"

    # Build packages for supported Ubuntu distributions
    declare -a arr=("jammy" "noble" "questing" "resolute")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$helix_VERSION-${BUILD_VERSION}+${dist}_${build_arch}_ubu"
        echo "  Building $FULL_VERSION"

        if ! docker build . -f Dockerfile.ubu -t "helix-ubuntu-$dist-$build_arch" \
            --build-arg UBUNTU_DIST="$dist" \
            --build-arg helix_VERSION="$helix_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg HELIX_RELEASE="$helix_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "helix-ubuntu-$dist-$build_arch")"
        if ! docker cp "$id:/helix_$FULL_VERSION.deb" - > "./helix_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./helix_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up extracted directory
    rm -rf "$helix_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building helix $helix_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la helix_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
