# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=

##
# Base container version
##
ARG BASE_VERSION=3.17.90

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
    commontorizon/gambas3${GPU}:${BASE_VERSION} AS Build

ARG IMAGE_ARCH
ARG APP_EXECUTABLE

COPY __change__ /build
WORKDIR /build

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# build
RUN gbc3 /build

# BUILD ------------------------------------------------------------------------



# DEPLOY -----------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    ghcr.io/microhobby/gambas3${GPU}:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG GPU
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /build/__change__/__change__.gambas /app
# coyp the assets
COPY __change__/assets /app/assets

# ADD YOUR ARGUMENTS HERE
CMD [ "./app/__change__.gambas" ]

# DEPLOY -----------------------------------------------------------------------
