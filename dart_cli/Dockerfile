# ARGUMENTS --------------------------------------------------------------------
ARG DART_TAG=stable-sdk

##
# Board architecture
# arm or arm64
##
ARG IMAGE_ARCH=

##
# Application Name
##
ARG APP_EXECUTABLE=main


# BUILD ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} dart:${DART_TAG} AS build

ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
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

RUN dart compile exe /app/bin/${APP_EXECUTABLE}.dart --output /app/${APP_EXECUTABLE}

# BUILD ------------------------------------------------------------------------


# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} dart:${DART_TAG} AS deploy

ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

RUN apt-get -y update && apt-get install -y --no-install-recommends \
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=build /app/${APP_EXECUTABLE} /app

# ADD YOUR ARGUMENTS HERE
CMD [ "/app/${APP_EXECUTABLE}" ]

# DEPLOY ------------------------------------------------------------------------
