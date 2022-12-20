FROM alpine:latest as download

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION

ENV BUILDX_ARCH="${TARGETOS:-linux}_${TARGETARCH:-amd64}${TARGETVARIANT}"

RUN wget https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && unzip pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && chmod +x /pocketbase

FROM alpine:latest
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

ENV LISTEN_HTTP "0.0.0.0:8090"
ENV PB_ENCRYPTION_KEY "replaceme"  # Overwritten in deployment

EXPOSE 8090

COPY --from=download /pocketbase /usr/local/bin/pocketbase
ENTRYPOINT "/usr/local/bin/pocketbase serve --http=${LISTEN_HTTP} --dir=/data --publicDir=/public --encryptionEnv=PB_ENCRYPTION_KEY"
