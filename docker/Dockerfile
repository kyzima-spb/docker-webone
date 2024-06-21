FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine3.19 as build

WORKDIR /usr/local/src/webone

ARG WEBONE_VERSION="0.17.0"
ARG WEBONE_BASE_URL="https://github.com/atauenis/webone/archive/refs/tags"

ADD ${WEBONE_BASE_URL}/v${WEBONE_VERSION}.tar.gz /tmp/webone.tar.gz

RUN tar --strip-components=1 -xzf /tmp/webone.tar.gz \
    && dotnet publish -r alpine-x64 -c Release -o /opt/webone/ --self-contained ./WebOne.csproj


FROM alpine:3.20

EXPOSE 8080

RUN adduser -s /usr/sbin/nologin -D webone \
    && apk update && apk add --no-cache \
        icu-libs \
        imagemagick \
        imagemagick-svg \
        imagemagick-pdf \
        ffmpeg \
        yt-dlp \
    && rm -rf /var/cache/apk/* \
    && ln -s /dev/null /var/log/webone.log

USER webone

WORKDIR /opt/webone

COPY --chown=webone --from=build /opt/webone .
COPY ./ /

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["./webone"]
