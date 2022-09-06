# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=
# For armv7 use:
#ARG IMAGE_ARCH=arm

##
# Base container version
##
ARG BASE_VERSION=2

##
# Application Name
##
ARG APP_EXECUTABLE=__change__
# ARGUMENTS --------------------------------------------------------------------



# BUILD ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizonextras/wayland-base:${BASE_VERSION} AS Build

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

COPY . /build
WORKDIR /build

# Install required packages
RUN apt-get -q -y update && \
    apt-get -q -y install \
    gcc \
    g++ \
    make \
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
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# install the latest node js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN npm config set registry https://registry.npmjs.org/
RUN npm install -g npm@8.10.0

# build the application
RUN npm install && \
    npx electron-forge package -a arm64 -p linux

# BUILD ------------------------------------------------------------------------



# DEPLOY -----------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizonextras/wayland-base:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

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
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
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
