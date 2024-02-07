# ARGUMENTS --------------------------------------------------------------------
##
# Base container version
##
ARG SDK_BASE_VERSION=1.74
ARG BASE_VERSION=3.2.1-bookworm

##
# Board architecture
##
ARG IMAGE_ARCH=

##
# Directory of the application inside container
##
ARG APP_ROOT=


# BUILD ------------------------------------------------------------------------
FROM rust:${SDK_BASE_VERSION} AS Build

ARG IMAGE_ARCH
ARG APP_ROOT

RUN apt-get update && \
    apt-get install -y \
    gcc-arm-linux-gnueabihf \
    gcc-aarch64-linux-gnu \
    # ADD YOUR PACKAGES HERE
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        echo aarch64-unknown-linux-gnu > ~/rust-toolchain-arch.txt; \
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        echo armv7-unknown-linux-gnueabihf > ~/rust-toolchain-arch.txt; \
    elif [ "$IMAGE_ARCH" = "amd64" ] ; then \
        echo x86_64-unknown-linux-gnu > ~/rust-toolchain-arch.txt; \
    fi

RUN rustup target add $(cat ~/rust-toolchain-arch.txt)

COPY . ${APP_ROOT}
WORKDIR ${APP_ROOT}

RUN TARGET=$(cat ~/rust-toolchain-arch.txt) && \
    cargo build --release --target $TARGET && \
    mkdir -p build && \
    cp -r target/$TARGET/release build

# BUILD ------------------------------------------------------------------------


# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/debian:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_ROOT

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Copy the application compiled in the build step to the $APP_ROOT directory
# path inside the container, where $APP_ROOT is the torizon_app_root
# configuration defined in settings.json
COPY --from=Build ${APP_ROOT}/build/release/__change__ ${APP_ROOT}/__change__

# "cd" (enter) into the APP_ROOT directory
WORKDIR ${APP_ROOT}

# Command executed in runtime when the container starts
CMD ["./__change__"]
# DEPLOY ------------------------------------------------------------------------
