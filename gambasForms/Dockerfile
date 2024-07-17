# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=

##
# Base container version
##
ARG BASE_VERSION=3.17.90-4-rc

##
# Directory of the application inside container
##
ARG APP_ROOT=

##
# Board GPU vendor prefix
##
ARG GPU=
# ARGUMENTS --------------------------------------------------------------------



# BUILD ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    commontorizon/gambas3${GPU}:${BASE_VERSION} AS Build

ARG IMAGE_ARCH
ARG APP_ROOT

COPY __change__ /build
WORKDIR /build

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_build_start__
    # __torizon_packages_build_end__
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
ARG APP_ROOT

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the assets
COPY __change__/assets ${APP_ROOT}/assets

# Copy the application compiled in the build step to the $APP_ROOT directory
# path inside the container, where $APP_ROOT is the torizon_app_root
# configuration defined in settings.json
COPY --from=Build /build/__change__/__change__.gambas ${APP_ROOT}

# "cd" (enter) into the APP_ROOT directory
WORKDIR ${APP_ROOT}

# Command executed in runtime when the container starts
CMD [ "./__change__.gambas" ]

# DEPLOY -----------------------------------------------------------------------
