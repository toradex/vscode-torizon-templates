# ARGUMENTS --------------------------------------------------------------------
##
# SDK container version
##
ARG SDK_BASE_VERSION=3
##
# Base container version
##
ARG BASE_VERSION=3

##
# Application Name
##
ARG APP_EXECUTABLE=__change__

##
# Board architecture
# arm or arm64
##
ARG IMAGE_ARCH=

##
# Board GPU vendor prefix
##
ARG GPU=

# BUILD ------------------------------------------------------------------------
# TODO: cross compile x86 to arm
# We will use emulation here
##
# Build Step
##
FROM --platform=linux/${IMAGE_ARCH} \
    torizon/qt6-wayland${GPU}:${SDK_BASE_VERSION} AS Build

ARG IMAGE_ARCH
ARG GPU

# for vivante GPU we need some "special" sauce
RUN apt-get -q -y update && \
        if [ "${GPU}" = "-vivante" ]; then \
            apt-get -q -y install \
            imx-gpu-viv-wayland-dev \
        ; else \
            apt-get -q -y install \
            libgl1 \
            libgles-dev \
        ; fi \
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
    build-essential \
    cmake \
    qt6-base-private-dev \
    qt6-base-dev \
    qt6-wayland \
    qt6-wayland-dev \
    qt6-declarative-dev \
    qt6-declarative-private-dev \
    qml6-module-qtqml \
    qml6-module-qtqml-workerscript \
    qml6-module-qtcore \
    qml6-module-qtquick \
    qml6-module-qtquick-window \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-templates \
    libqt6opengl6-dev \
    # ADD YOUR PACKAGES HERE
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# __deps__

COPY . /app
WORKDIR /app

RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -Bbuild ; \
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -Bbuild ; \
    fi

RUN cmake --build build

# DEPLOY ------------------------------------------------------------------------
##
# Deploy Step
##
FROM --platform=linux/${IMAGE_ARCH} \
    torizon/qt6-wayland${GPU}:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

# SSH for remote debug
EXPOSE 2231
ARG SSHUSERNAME=torizon

# Make sure we don't get notifications we can't answer during building.
ENV DEBIAN_FRONTEND="noninteractive"

# for vivante GPU we need some "special" sauce
RUN apt-get -q -y update && \
        if [ "${GPU}" = "-vivante" ]; then \
            apt-get -q -y install \
            imx-gpu-viv-wayland-dev \
        ; else \
            apt-get -q -y install \
            libgl1 \
            libgles-dev \
        ; fi \
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# your regular RUN statements here
# Install required packages
RUN apt-get -q -y update && \
    apt-get -q -y install \
    file \
    curl \
    qt6-base-private-dev \
    qt6-base-dev \
    qt6-wayland \
    qt6-wayland-dev \
    qt6-declarative-dev \
    qt6-declarative-private-dev \
    qml6-module-qtqml \
    qml6-module-qtqml-workerscript \
    qml6-module-qtcore \
    qml6-module-qtquick \
    qml6-module-qtquick-window \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-templates \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY --from=Build /app/build /app
USER torizon
WORKDIR /app/debug

CMD [ "./__change__" ]
