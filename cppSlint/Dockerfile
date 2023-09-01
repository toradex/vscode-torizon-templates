## using Slint v1.1.1 base images
ARG CROSS_SDK_BASE_TAG=3.0.9-bookworm-1.1.1
ARG BASE_VERSION=3.0.8
##
# Board architecture
# arm or arm64
##
ARG IMAGE_ARCH=

##
# Application Name
##
ARG APP_EXECUTABLE=__change__

##
# Board GPU vendor prefix
##
ARG GPU=


# BUILD ------------------------------------------------------------------------
FROM commontorizon/slint-sdk-${IMAGE_ARCH}:${CROSS_SDK_BASE_TAG} As Build

ARG IMAGE_ARCH
ARG GPU
ARG COMPILER_ARCH
ENV IMAGE_ARCH ${IMAGE_ARCH}

# Rust
ENV RUSTUP_HOME=/rust
ENV CARGO_HOME=/cargo
ENV PATH=/cargo/bin:/rust/bin:$PATH

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# __deps__

# Don't require font-config when the compiler runs
ENV RUST_FONTCONFIG_DLOPEN=on

# Default to Ninja
ENV CMAKE_GENERATOR=Ninja

COPY . /app
WORKDIR /app

RUN mkdir -p build \
    && cd build \
    && cmake .. \
    && cmake --build .

# BUILD ------------------------------------------------------------------------


# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/wayland-base${GPU}:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

# Install Slint dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install libfontconfig1 libxkbcommon0 fonts-noto-core fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-color-emoji fonts-noto-ui-core fonts-noto-ui-extra \
    && rm -rf /var/lib/apt/lists/*

# copy Slint library
COPY --from=Build /usr/lib/libslint* /usr/lib

# for vivante GPU we need some "special" sauce
RUN apt-get -q -y update && \
        if [ "${GPU}" = "-vivante" ]; then \
            apt-get -q -y install \
            imx-gpu-viv-wayland-dev \
        ; else \
            apt-get -q -y install \
            libgl1 \
        ; fi \
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /app/build /app

# Default to the Skia backend for best performance
ENV SLINT_BACKEND=winit-skia
# Default to Slint running in fullscreen
ENV SLINT_FULLSCREEN=1

# ADD YOUR ARGUMENTS HERE
CMD [ "./__change__" ]

# DEPLOY ------------------------------------------------------------------------
