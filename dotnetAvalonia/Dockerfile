# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=

##
# Base container version
##
ARG BASE_VERSION=3
ARG DOTNET_BASE_VERSION=3-6.0

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
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS Build

ARG IMAGE_ARCH
ARG APP_EXECUTABLE

COPY . /build
WORKDIR /build

# build
RUN dotnet restore && \
dotnet publish -c Release -r linux-${IMAGE_ARCH} --no-self-contained
# BUILD ------------------------------------------------------------------------

# DOTNET -----------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizon/dotnet:${DOTNET_BASE_VERSION} AS Dotnet


# DEPLOY -----------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizon/wayland-base${GPU}:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

ENV DOTNET_ROOT=/dotnet
ENV PATH=$PATH:/dotnet

COPY --from=Dotnet /dotnet /dotnet

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
    # ADD YOUR PACKAGES HERE
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    libice6 \
    libsm6 \
    libicu72 \
    curl \
    gettext \
    apt-transport-https \
    libx11-6 \
	libunwind-13 \
    icu-devtools \
	libfontconfig1 \
	libgtk-3-0 \
    libgtk-3-bin \
    libgtk-3-common \
	libdrm2 \
	libinput10 \
    libssl3 \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN printf "{\n  \"device\": \"/dev/dri/card1\",\n  \"outputs\": [ { \"name\": \"HDMI1\" } ],\n  \"hwcursor\": false\n}" > /etc/kms-imx6.conf \
    && printf "{\n  \"hwcursor\": false\n}" > /etc/kms-imx8.conf \
    && ln -s /etc/kms-imx8.conf /etc/kms-imx7.conf

# copy the build
COPY --from=Build /build/bin/Release/net6.0/linux-${IMAGE_ARCH}/publish /app

# ADD YOUR ARGUMENTS HERE
CMD [ "./app/__change__" ]
# DEPLOY -----------------------------------------------------------------------
