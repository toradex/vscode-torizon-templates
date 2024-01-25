# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=

##
# Base container version
##
ARG SDK_BASE_VERSION=4-8.0-rc
ARG BASE_VERSION=4-rc

##
# Application Name
##
ARG APP_EXECUTABLE=__change__

##
# Board GPU vendor prefix
##
ARG GPU=

# ARGUMENTS --------------------------------------------------------------------



# BUILD ------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS Build

ARG IMAGE_ARCH
ARG APP_EXECUTABLE

# this is needed for the build to work witht he libslint
RUN apt-get -q -y update && \
    apt-get -q -y install \
    libfontconfig1

COPY . /build
WORKDIR /build

# build
RUN dotnet restore && \
    dotnet publish -c Release -r linux-${IMAGE_ARCH}
# BUILD ------------------------------------------------------------------------



# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizon/wayland-base${GPU}:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

# for vivante GPU we need some "special" sauce
RUN apt-get -q -y update && \
        if [ "${GPU}" = "-vivante" ] || [ "${GPU}" = "-imx8" ]; then \
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
# Install Slint and .net dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install \
    libfontconfig1 \
    libxkbcommon0 \
    fonts-noto-core \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-noto-ui-core \
    fonts-noto-ui-extra \
    libicu72 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -y update && apt-get install -y --no-install-recommends \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /build/bin/Release/net8.0/linux-${IMAGE_ARCH}/publish /app

# Default to the Skia backend for best performance
ENV SLINT_BACKEND=winit-skia
# Default to Slint running in fullscreen
ENV SLINT_FULLSCREEN=1
# Default style to fluent
ENV SLINT_STYLE=fluent

WORKDIR /app

# ADD YOUR ARGUMENTS HERE
CMD [ "./__change__" ]

# DEPLOY ------------------------------------------------------------------------
