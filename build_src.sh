#!/bin/bash
set -euo pipefail

helix_VERSION=$1
BUILD_VERSION=$2

if [ -z "$helix_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <helix_version> <build_version>"
    echo "Example: $0 1.2.3 1"
    exit 1
fi

PACKAGE_NAME="helix"

# TODO: implement helix build
#
# This should mirror uv-debian's build_src.sh: download the upstream source
# tarball for https://github.com/helix-editor/helix, generate a per-distribution debian/changelog,
# and run `dpkg-source -b` for each supported Debian/Ubuntu distribution.
echo "build_src.sh for ${PACKAGE_NAME} is not implemented yet."
exit 1
