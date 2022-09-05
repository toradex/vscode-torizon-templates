# ARGUMENTS --------------------------------------------------------------------
##
# Base container version
##
ARG BASE_VERSION=2
ARG SDK_BASE_VERSION=2.5-bullseye

##
# Application Name
##
ARG APP_EXECUTABLE=__change__

##
# Board architecture
# arm or arm64
##
ARG IMAGE_ARCH=

# TODO: cross compile x86 to arm
# We will use emulation here
# BUILD ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizonextras/debian:${SDK_BASE_VERSION} AS Build

ARG IMAGE_ARCH

# add the backports to get Qt6 packages
RUN echo "deb http://deb.debian.org/debian bullseye-backports main" >> \
    /etc/apt/sources.list

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
    build-essential \
    qmake6 \
    qt6-base-private-dev \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-declarative-private-dev \
    libqt6opengl6-dev \
    # ADD YOUR PACKAGES HERE
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# __deps__

COPY . /app
WORKDIR /app

RUN qmake6 -o build/Makefile && \
    cd build && \
    make

# Deploy ------------------------------------------------------------------------
##
# Deploy Step
##
FROM --platform=linux/${IMAGE_ARCH} \
    torizonextras/wayland-base:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

# SSH for remote debug
EXPOSE 2231
ARG SSHUSERNAME=torizon

# Make sure we don't get notifications we can't answer during building.
ENV DEBIAN_FRONTEND="noninteractive"

# add the backports to get Qt6 packages
RUN echo "deb http://deb.debian.org/debian bullseye-backports main" >> \
    /etc/apt/sources.list

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
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY --from=Build /app/build /app
USER torizon
WORKDIR /app/debug

CMD [ "./__change__" ]
