ARG DOTNET_SDK_VERSION="8.0"
ARG ALPINE_VERSION="3.20"

FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_SDK_VERSION}-alpine${ALPINE_VERSION} AS build

WORKDIR /usr/local/src/webone

ARG WEBONE_VERSION="0.17.1"
ARG WEBONE_BASE_URL="https://github.com/atauenis/webone/archive/refs/tags"

ADD ${WEBONE_BASE_URL}/v${WEBONE_VERSION}.tar.gz /tmp/webone.tar.gz

RUN --mount=type=cache,target=/root/.nuget/packages \
    tar --strip-components=1 -xzf /tmp/webone.tar.gz \
    && dotnet publish -r alpine-x64 -c Release -o ./dist --self-contained ./WebOne.csproj \
    && mkdir ./dist/webone.conf.d


FROM alpine:3.20

HEALTHCHECK --start-period=30s --interval=10s --timeout=5s --retries=3 \
    CMD curl -f http://127.0.0.1:8080 || exit 1

ENV HOME=/tmp

EXPOSE 8080

WORKDIR /tmp

RUN --mount=type=cache,target=/var/cache/apk,sharing=locked \
    apk update && apk add \
        curl \
        ffmpeg \
        icu-libs \
        imagemagick \
        imagemagick-svg \
        imagemagick-pdf \
        yt-dlp \
    && adduser -s /usr/sbin/nologin -D webone \
    && ln -s /opt/webone/webone /usr/local/bin/webone \
    && ln -s /dev/null /var/log/webone.log

COPY --from=build /usr/local/src/webone/dist /opt/webone
COPY ./ /

USER webone

ENTRYPOINT ["docker-entrypoint.sh"]
