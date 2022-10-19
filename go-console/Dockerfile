ARG CROSS_SDK_BASE_TAG=2.6-bullseye
ARG BASE_VERSION=2.5-bullseye

##
# Board architecture
# arm or arm64
##
ARG IMAGE_ARCH=


##
# Application Name
##
ARG APP_EXECUTABLE=golangtest


# BUILD ------------------------------------------------------------------------
FROM golang:1.19.2-bullseye AS Build

ARG IMAGE_ARCH
ENV IMAGE_ARCH ${IMAGE_ARCH}

RUN apt-get update && \
    apt-get install -y \
    gcc-arm-linux-gnueabihf \
    gcc-aarch64-linux-gnu \
    # ADD YOUR PACKAGES HERE
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY /src /app

WORKDIR /app


RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
    env GOOS=linux GOARCH=arm64 go build -o main; \
    elif [ "$IMAGE_ARCH" = "arm32" ] ; then \
    env GOOS=linux GOARCH=arm go build -o main; \
    fi


ARG UNAME=gouser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME


# BUILD ------------------------------------------------------------------------


# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/debian:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /app/main /home/torizon

# ADD YOUR ARGUMENTS HERE
CMD [ "./home/torizon/main" ]

# DEPLOY ------------------------------------------------------------------------
