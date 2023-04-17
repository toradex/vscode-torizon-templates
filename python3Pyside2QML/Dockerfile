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
ARG BASE_VERSION=3

ARG APP_ROOT=/home/torizon

FROM --platform=linux/${IMAGE_ARCH} \
     torizon/wayland-base:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE

# your regular RUN statements here
# Install required packages
RUN apt-get -q -y update && \
    apt-get -q -y install \
    python3-minimal \
    python3-pip \
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
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    && apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY requirements-release.txt /requirements-release.txt
RUN pip3 install --upgrade pip && pip3 install -r requirements-release.txt && rm requirements-release.txt

# copy the source code
COPY /src ${APP_ROOT}/src

WORKDIR ${APP_ROOT}/src

CMD [ "/usr/bin/python3", "main.py", "--no-sandbox" ]
