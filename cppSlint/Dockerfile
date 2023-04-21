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


# BUILD ------------------------------------------------------------------------
FROM torizon/debian-cross-toolchain-${IMAGE_ARCH}:${CROSS_SDK_BASE_TAG} As Build

ARG IMAGE_ARCH
ARG COMPILER_ARCH
ENV IMAGE_ARCH ${IMAGE_ARCH}

# Install an up-to-date cmake as well as ninja and make
RUN apt-get update && \
    apt-get install --assume-yes gpg wget && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
    apt-get update && \
    apt-get install --assume-yes cmake ninja-build make && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=755 armhf-toolchain.cmake arm64-toolchain.cmake /

RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        echo aarch64-unknown-linux-gnu > /rust-toolchain-arch.txt; \
        echo arm64 > /cross-toolchain-arch.txt; \
        dpkg-divert --divert /usr/bin/cmake.real --rename /usr/bin/cmake; \
        printf '#!/bin/sh\nexport CMAKE_TOOLCHAIN_FILE=/arm64-toolchain.cmake\nexec /usr/bin/cmake.real $*\n' > /usr/bin/cmake; \
        chmod 755 /usr/bin/cmake ;\
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        echo armv7-unknown-linux-gnueabihf > /rust-toolchain-arch.txt; \
        echo armhf > /cross-toolchain-arch.txt; \
        dpkg-divert --divert /usr/bin/cmake.real --rename /usr/bin/cmake; \
        printf '#!/bin/sh\nexport CMAKE_TOOLCHAIN_FILE=/armhf-toolchain.cmake\nexec /usr/bin/cmake.real $*\n' > /usr/bin/cmake; \
        chmod 755 /usr/bin/cmake ;\
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

# Install Slint build dependencies (libxcb, etc.)
RUN \
    --mount=type=cache,target=/var/cache/apt \
    CROSS_TOOLCHAIN_ARCH=$(cat /cross-toolchain-arch.txt) && \
    apt-get update && \
    apt-get install --assume-yes libfontconfig1-dev:$CROSS_TOOLCHAIN_ARCH libxcb1-dev:$CROSS_TOOLCHAIN_ARCH libxcb-render0-dev:$CROSS_TOOLCHAIN_ARCH libxcb-shape0-dev:$CROSS_TOOLCHAIN_ARCH libxcb-xfixes0-dev:$CROSS_TOOLCHAIN_ARCH libxkbcommon-dev:$CROSS_TOOLCHAIN_ARCH python3 clang libstdc++-10-dev:$CROSS_TOOLCHAIN_ARCH && \
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

# Default to Ninja
ENV CMAKE_GENERATOR=Ninja

# Build Slint
RUN git clone https://github.com/slint-ui/slint --depth 1 --branch release/1 /slint
RUN RUST_TOOLCHAIN_ARCH=$(cat /rust-toolchain-arch.txt) && \
    cd /slint \
    && mkdir build \
    && cd build \
    && cmake -DRust_CARGO_TARGET=$RUST_TOOLCHAIN_ARCH .. \
       -DCMAKE_INSTALL_PREFIX=/usr \
       -DCMAKE_BUILD_TYPE=Release \
       -DSLINT_FEATURE_RENDERER_WINIT_SKIA=ON -DSLINT_FEATURE_RENDERER_WINIT_FEMTOVG=OFF \
       -DSLINT_FEATURE_BACKEND_WINIT=OFF -DSLINT_FEATURE_BACKEND_WINIT_WAYLAND=ON \
    && cmake --build . \
    && cmake --install . \
    && cd / \
    && rm -rf /slint

COPY . /app
WORKDIR /app

RUN mkdir -p build \
    && cd build \
    && cmake .. \
    && cmake --build .

# BUILD ------------------------------------------------------------------------


# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/wayland-base:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

# Install Slint dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install libfontconfig1 libxkbcommon0 fonts-noto-core fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-color-emoji fonts-noto-ui-core fonts-noto-ui-extra \
    && rm -rf /var/lib/apt/lists/*

# copy Slint library
COPY --from=Build /usr/lib/libslint* /usr/lib

RUN apt-get -y update && apt-get install -y --no-install-recommends \
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
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
