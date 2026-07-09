ARG DEBIAN_DIST=bookworm
FROM debian:bookworm

ARG DEBIAN_DIST
ARG helix_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION
ARG ARCH
ARG HELIX_RELEASE

# TODO: implement helix build.
# This Dockerfile mirrors uv-debian's structure but is not wired up to any
# real build logic yet: build_debian.sh currently exits before invoking
# `docker build`, and the output/ packaging skeleton below has not been
# created for helix. Fill in output/DEBIAN/control, output/copyright,
# output/changelog.Debian and output/README.md, then point COPY at the
# downloaded helix release, before using this file.

RUN mkdir -p /output/usr/bin
RUN mkdir -p /output/usr/share/doc/helix
RUN mkdir -p /output/DEBIAN

# COPY ${HELIX_RELEASE}/* /output/usr/bin/
# COPY output/DEBIAN/control /output/DEBIAN/
# COPY output/copyright /output/usr/share/doc/helix/
# COPY output/changelog.Debian /output/usr/share/doc/helix/
# COPY output/README.md /output/usr/share/doc/helix/

# RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/usr/share/doc/helix/changelog.Debian
# RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/helix/changelog.Debian
# RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/control
# RUN sed -i "s/helix_VERSION/$helix_VERSION/" /output/DEBIAN/control
# RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
# RUN sed -i "s/SUPPORTED_ARCHITECTURES/$ARCH/" /output/DEBIAN/control

# RUN dpkg-deb --build /output /helix_${FULL_VERSION}.deb
