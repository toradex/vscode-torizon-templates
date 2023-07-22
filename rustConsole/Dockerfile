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
FROM rust:1.48 AS Build

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV IMAGE_ARCH ${IMAGE_ARCH}

RUN apt-get update && \
    apt-get install -y \
    gcc-arm-linux-gnueabihf \
    gcc-aarch64-linux-gnu \
    # ADD YOUR PACKAGES HERE
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

ARG UNAME=rustuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME

RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        echo aarch64-unknown-linux-gnu > ~/rust-toolchain-arch.txt; \
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        echo armv7-unknown-linux-gnueabihf > ~/rust-toolchain-arch.txt; \
    elif [ "$IMAGE_ARCH" = "amd64" ] ; then \
        echo x86_64-unknown-linux-gnu > ~/rust-toolchain-arch.txt; \
    fi

RUN rustup target add $(cat ~/rust-toolchain-arch.txt)

WORKDIR /app

COPY . /app

RUN TARGET=$(cat ~/rust-toolchain-arch.txt) && \
    cargo build --release --target $TARGET && \
    mkdir -p target/deploy && \
    cp target/$TARGET/release/$APP_EXECUTABLE target/deploy

# BUILD ------------------------------------------------------------------------


# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/debian:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /app/target/deploy/${APP_EXECUTABLE} /usr/bin/${APP_EXECUTABLE}

# ADD YOUR ARGUMENTS HERE
CMD ${APP_EXECUTABLE}

# DEPLOY ------------------------------------------------------------------------
