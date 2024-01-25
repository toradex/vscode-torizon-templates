# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=



##
# Base container version
##
ARG BASE_VERSION=3.2.1

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
FROM --platform=linux/${IMAGE_ARCH} \
    torizon/wayland-base${GPU}:${BASE_VERSION} AS Build

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

COPY . /build
WORKDIR /build

# stick to bookworm on /etc/apt/sources.list.d
RUN sed -i 's/sid/bookworm/g' /etc/apt/sources.list.d/debian.sources

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

# Install required packages
RUN apt-get -q -y update && \
    apt-get -q -y install \
    gcc \
    g++ \
    make \
    git \
    libatspi2.0-0 \
    libgconf-2-4 \
    libglib2.0-bin \
    libgtk2.0-0 \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libuuid1 \
    libxcb-dri3-0 \
    xdg-utils \
    libxss1 \
    libxtst6 \
    libasound2 \
    curl \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# install the latest node js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN npm config set registry https://registry.npmjs.org/
RUN npm install -g npm@8.10.0

# build the application
# overwrite the EGL lib for vivante GPU
RUN npm install && \
    npx electron-forge package -a arm64 -p linux && \
    if [ "${GPU}" = "-vivante" ] || [ "${GPU}" = "-imx8" ]; then \
        cp /usr/lib/aarch64-linux-gnu/libEGL.so /build/out/__change__-linux-${IMAGE_ARCH} && \
        cp /usr/lib/aarch64-linux-gnu/libGLESv2.so /build/out/__change__-linux-${IMAGE_ARCH}; \
    fi

# BUILD ------------------------------------------------------------------------



# DEPLOY -----------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizon/wayland-base${GPU}:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

# stick to bookworm on /etc/apt/sources.list.d
RUN sed -i 's/sid/bookworm/g' /etc/apt/sources.list.d/debian.sources

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

# your regular RUN statements here
# Install required packages
RUN apt-get -q -y update && \
    apt-get -q -y install \
    libatspi2.0-0 \
    libgconf-2-4 \
    libglib2.0-bin \
    libgtk2.0-0 \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libuuid1 \
    libxcb-dri3-0 \
    xdg-utils \
    libxss1 \
    libxtst6 \
    libasound2 \
    curl \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# install the latest node js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# copy the build
COPY --from=Build /build/out/__change__-linux-${IMAGE_ARCH} /app
WORKDIR /app

CMD [ "__change__", "--no-sandbox" ]

# DEPLOY -----------------------------------------------------------------------
