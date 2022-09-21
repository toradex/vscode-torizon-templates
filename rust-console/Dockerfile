ARG CROSS_SDK_BASE_TAG=2.6-bullseye
ARG BASE_VERSION=2.5-bullseye

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

RUN apt-get update && \
    apt-get install -y \
    gcc-arm-linux-gnueabihf \
    gcc-aarch64-linux-gnu \
    # ADD YOUR PACKAGES HERE
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN rustup target add aarch64-unknown-linux-gnu && \
    rustup target add armv7-unknown-linux-gnueabihf

ARG UNAME=rustuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME

WORKDIR /app

COPY . /app

RUN mkdir -p output

RUN if [ "$IMAGE_ARCH" == "arm64" ] ; then \
    cargo build --target aarch64-unknown-linux-gnu; \
    elif [ "$IMAGE_ARCH" == "arm32" ] ; then \
    cargo build --target armv7-unknown-linux-gnueabihf; \
    fi

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
COPY --from=Build /app/debug /app

# ADD YOUR ARGUMENTS HERE
CMD [ "./app/main" ]

# DEPLOY ------------------------------------------------------------------------
