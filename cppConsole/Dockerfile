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
ARG APP_EXECUTABLE=__change__


# BUILD ------------------------------------------------------------------------
FROM torizon/debian-cross-toolchain-${IMAGE_ARCH}:${CROSS_SDK_BASE_TAG} As Build

ARG IMAGE_ARCH
ARG COMPILER_ARCH
ENV IMAGE_ARCH ${IMAGE_ARCH}}

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
    # ADD YOUR PACKAGES HERE
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# __deps__

COPY . /app
WORKDIR /app

RUN if [ $IMAGE_ARCH == "arm64" ] ; then \
    make CC=aarch64-linux-gnu-g++ ; \
    elif [ $IMAGE_ARCH == "arm" ] ; then \
    make CC=arm-linux-gnueabihf-g++ ; \
    elif [ $IMAGE_ARCH == "amd64" ] ; then \
    make CC=x86_64-linux-gnu-g++ ; \
    fi

# BUILD ------------------------------------------------------------------------


# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizonextras/debian:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /app/debug /app

# ADD YOUR ARGUMENTS HERE
CMD [ "./app/main" ]

# DEPLOY ------------------------------------------------------------------------
