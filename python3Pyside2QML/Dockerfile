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
ARG BASE_VERSION=3.0.9-bookworm

ARG APP_ROOT=/home/torizon

##
# Board GPU vendor prefix
##
ARG GPU=

FROM --platform=linux/${IMAGE_ARCH} \
     torizon/wayland-base${GPU}:${BASE_VERSION} AS opengles

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ARG APP_ROOT

# Make sure we don't get notifications we can't answer during building.
ENV DEBIAN_FRONTEND="noninteractive"

# Install required packages
RUN apt-get -q -y update && \
    apt-get -q -y install \
    libqt5gui5-gles libqt5quick5-gles \
    && apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*


FROM --platform=linux/${IMAGE_ARCH} \
     torizon/wayland-base${GPU}:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ARG APP_ROOT

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

# your regular RUN statements here
# Install required packages
RUN apt-get -q -y update && \
    apt-get -q -y install \
    python3-minimal \
    python3-pip \
    python3-venv \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls2 \
    qml-module-qtquick2 \
    python3-pyside2.qtwidgets \
    python3-pyside2.qtgui \
    python3-pyside2.qtqml \
    python3-pyside2.qtcore \
    python3-pyside2.qtquick \
    python3-pyside2.qtnetwork \
    qml-module-qtquick-dialogs \
    qtwayland5 \
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# replace the libs from the opengles image
COPY --from=opengles /usr/lib/aarch64-linux-gnu /usr2/lib/aarch64-linux-gnu
# rsync the files
RUN rsync -a /usr2/lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu && \
    rm -rf /usr2

# Create virtualenv
RUN python3 -m venv ${APP_ROOT}/.venv --system-site-packages

# Install pip packages on venv
COPY requirements-release.txt /requirements-release.txt
RUN . ${APP_ROOT}/.venv/bin/activate && \
    pip3 install --upgrade pip && pip3 install -r requirements-release.txt && \
    rm requirements-release.txt

USER torizon

# copy the source code
COPY /src ${APP_ROOT}/src

WORKDIR ${APP_ROOT}

ENV APP_ROOT=${APP_ROOT}
ENV QT_QPA_PLATFORM="wayland"

# Activate and run the code
CMD . ${APP_ROOT}/.venv/bin/activate && python3 src/main.py --no-sandbox
