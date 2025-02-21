ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="florian.sipp@chuv.ch"

ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/curl,sharing=locked \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy \
        unzip \
        ca-certificates \
        curl \
        libpng-dev \
        libtiff-dev \
        libjpeg-dev \
        libfftw3-dev \
        libgsl-dev \
        libdcmtk-dev \
        libexpat1-dev \
        libx11-dev \
        libxt-dev \
        libglu1-mesa-dev \
        libxi-dev \
        libxmu-dev \
        libxmu-headers \
        libtbb-dev \
        libeigen3-dev && \
    curl -sSL -C - -O "https://github.com/ANTsX/ANTs/releases/download/v${APP_VERSION}/ants-${APP_VERSION}-ubuntu-22.04-X64-gcc.zip" && \
    unzip -q ants-${APP_VERSION}-ubuntu-22.04-X64-gcc.zip && \
    rm ants-${APP_VERSION}-ubuntu-22.04-X64-gcc.zip && \
    apt-get remove -y --purge \
        curl unzip && \
    apt-get autoremove -y --purge

ENV APP_CMD_PREFIX="export PATH=/apps/${APP_NAME}/ants-${APP_VERSION}/bin:${PATH}"
ENV APP_SPECIAL="no"
ENV APP_CMD="/usr/bin/wezterm"
ENV PROCESS_NAME="/usr/bin/wezterm"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
