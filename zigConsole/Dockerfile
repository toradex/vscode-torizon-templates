ARG CROSS_SDK_BASE_TAG=3.0.9-bookworm
ARG BASE_VERSION=3.0.8-bookworm
##
# Board architecture
# arm or arm64
##
ARG IMAGE_ARCH=

##
# Application Name
##
ARG APP_EXECUTABLE=__change__


# BUILD ------------------------------------------------------------------------
FROM torizon/debian-cross-toolchain-${IMAGE_ARCH}:${CROSS_SDK_BASE_TAG} As Build

ARG IMAGE_ARCH
ARG COMPILER_ARCH
ENV IMAGE_ARCH ${IMAGE_ARCH}
ENV ZIG_PATH /zig/0.11.0/files

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
    wget unzip \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# __deps__

# Install Zig 0.11.0 (uses LLVM-16.0.6)
RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        wget -q https://github.com/kassane/zigup/releases/download/2023_09_29/zigup.ubuntu-latest-aarch64.zip && \
        unzip zigup.ubuntu-latest-aarch64.zip -d /usr/bin && \
        chmod +x /usr/bin/zigup && \
        zigup --install-dir /zig 0.11.0 ; \
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        wget -q https://github.com/kassane/zigup/releases/download/2023_09_29/zigup.ubuntu-latest-armv7a.zip && \
        unzip zigup.ubuntu-latest-armv7a.zip -d /usr/bin && \
        chmod +x /usr/bin/zigup && \
        zigup --install-dir /zig 0.11.0 ; \
    elif [ "$IMAGE_ARCH" = "amd64" ] ; then \
        wget -q https://github.com/kassane/zigup/releases/download/2023_09_29/zigup.ubuntu-latest-x86_64.zip && \
        unzip zigup.ubuntu-latest-x86_64.zip -d /usr/bin && \
        chmod +x /usr/bin/zigup && \
        zigup --install-dir /zig 0.11.0; \
    fi

RUN chmod +x ${ZIG_PATH}/zig

ARG UNAME=ziguana
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME

# default linux-libc: host - glibc (most), cross-compilation - musl (static)
# zig pure-code (no ffi), no need libc linking

# for glibc choose version:
# e.g.: -Dtarget=$TARGET-gnu.2.20 (my host has 2.36 [default], but my target use old version)
# for cross-compilation to glibc, use minimum version (2.19) supported.

# C++: zig uses llvm-libcxx/abi + llvm-unwind on almost all (LLVM)targets. [builtin static-linking]

WORKDIR /app
COPY . /app

# zig optimizers:
# (Debug | ReleaseSafe) w/ dbg-info + runtime stacktrace (compiler safety),
# (ReleaseSmall | ReleaseFast) no runtime stacktrace (undefined & fast)
RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        zig build -Doptimize=ReleaseSmall -Dtarget=aarch64-linux-gnu --summary all -freference-trace ; \
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        zig build -Doptimize=ReleaseSmall -Dtarget=arm-linux-gnu --summary all -freference-trace ; \
    elif [ "$IMAGE_ARCH" = "amd64" ] ; then \
        zig build -Doptimize=ReleaseSmall -Dtarget=x86_64-linux-gnu --summary all -freference-trace ; \
    fi

# BUILD ------------------------------------------------------------------------

RUN mkdir -p target/deploy && \
    if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        cp zig-out/aarch64/ReleaseSmall/bin/$APP_EXECUTABLE target/deploy ; \
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        cp zig-out/arm/ReleaseSmall/bin/$APP_EXECUTABLE target/deploy ; \
    elif [ "$IMAGE_ARCH" = "amd64" ] ; then \
        cp zig-out/x86_64/ReleaseSmall/bin/$APP_EXECUTABLE target/deploy ; \
    fi

# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/debian:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

RUN apt-get -y update && apt-get install -y --no-install-recommends \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /app/target/deploy/${APP_EXECUTABLE} /usr/bin/${APP_EXECUTABLE}

# ADD YOUR ARGUMENTS HERE
CMD ${APP_EXECUTABLE}

# DEPLOY ------------------------------------------------------------------------
