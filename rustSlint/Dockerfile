ARG CROSS_SDK_BASE_TAG=3-bookworm
ARG BASE_VERSION=3
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
FROM torizon/debian-cross-toolchain-${IMAGE_ARCH}:${CROSS_SDK_BASE_TAG} As Build

ARG IMAGE_ARCH
ARG GPU
ARG COMPILER_ARCH
ARG APP_EXECUTABLE
ENV IMAGE_ARCH ${IMAGE_ARCH}

RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        echo aarch64-unknown-linux-gnu > /rust-toolchain-arch.txt; \
        echo arm64 > /cross-toolchain-arch.txt; \
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        echo armv7-unknown-linux-gnueabihf > /rust-toolchain-arch.txt; \
        echo armhf > /cross-toolchain-arch.txt; \
    elif [ "$IMAGE_ARCH" = "amd64" ] ; then \
        echo x86_64-unknown-linux-gnu > /rust-toolchain-arch.txt; \
        echo amd64 > /cross-toolchain-arch.txt; \
    fi

# Install Rust
ENV RUSTUP_HOME=/rust
ENV CARGO_HOME=/cargo
ENV PATH=/cargo/bin:/rust/bin:$PATH

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN rustup target add $(cat /rust-toolchain-arch.txt)

RUN mkdir -p /cargo/registry && chmod 777 /cargo/registry

# Install Slint build dependencies (libxcb, etc.)
RUN \
    --mount=type=cache,target=/var/cache/apt \
    CROSS_TOOLCHAIN_ARCH=$(cat /cross-toolchain-arch.txt) && \
    apt-get update && \
    apt-get install --assume-yes libfontconfig1-dev:$CROSS_TOOLCHAIN_ARCH libxcb1-dev:$CROSS_TOOLCHAIN_ARCH libxcb-render0-dev:$CROSS_TOOLCHAIN_ARCH libxcb-shape0-dev:$CROSS_TOOLCHAIN_ARCH libxcb-xfixes0-dev:$CROSS_TOOLCHAIN_ARCH libxkbcommon-dev:$CROSS_TOOLCHAIN_ARCH python3 clang libstdc++-11-dev:$CROSS_TOOLCHAIN_ARCH && \
    rm -rf /var/lib/apt/lists/*

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# __deps__

# Don't require font-config when the compiler runs
ENV RUST_FONTCONFIG_DLOPEN=on

COPY . /app
WORKDIR /app

# BUILD ------------------------------------------------------------------------

RUN TARGET=$(cat /rust-toolchain-arch.txt) && \
    cargo build --release --target $TARGET && \
    mkdir -p target/deploy && \
    cp target/$TARGET/release/$APP_EXECUTABLE target/deploy

# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/wayland-base${GPU}:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

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

# Install Slint dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install libfontconfig1 libxkbcommon0 fonts-noto-core fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-color-emoji fonts-noto-ui-core fonts-noto-ui-extra \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /app/target/deploy/${APP_EXECUTABLE} /app

# Default to the Skia backend for best performance
ENV SLINT_BACKEND=winit-skia
# Default to Slint running in fullscreen
ENV SLINT_FULLSCREEN=1

# ADD YOUR ARGUMENTS HERE
CMD [ "./app" ]

# DEPLOY ------------------------------------------------------------------------
