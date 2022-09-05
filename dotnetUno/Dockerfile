# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=

##
# Base container version
##
ARG BASE_VERSION=2-6.0

##
# Application Name
##
ARG APP_EXECUTABLE=__change__.Skia.Gtk
# ARGUMENTS --------------------------------------------------------------------



# BUILD ------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS Build

ARG IMAGE_ARCH
ARG APP_EXECUTABLE

COPY . /build
WORKDIR /build/__change__.Skia.Gtk

# build
RUN dotnet restore && \
	dotnet build && \
	dotnet build -r linux-${IMAGE_ARCH} && \
	dotnet publish -r linux-${IMAGE_ARCH}
# BUILD ------------------------------------------------------------------------



# DEPLOY -----------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizonextras/dotnet-uno-debug:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    # ADD YOUR PACKAGES HERE
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DOES NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /build/__change__.Skia.Gtk/bin/Debug/net6.0/linux-${IMAGE_ARCH}/publish /app

# ADD YOUR ARGUMENTS HERE
CMD [ "./app/__change__.Skia.Gtk" ]
# DEPLOY -----------------------------------------------------------------------
