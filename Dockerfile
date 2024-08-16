FROM golang:1.21-alpine3.19 as build

ARG DOCKER_AUTH_VER 1.12.0
ARG DOCKER_AUTH_REF 6d81420dab2741213bd6e61936ba91a80c439679

ARG VERSION
ENV VERSION "${VERSION}"

ARG BUILD_ID
ENV BUILD_ID "${BUILD_ID}"

ARG CGO_EXTRA_CFLAGS

RUN apk add -U --no-cache ca-certificates make git gcc musl-dev binutils-gold

WORKDIR /src

# hadolint ignore=DL3003
RUN git clone https://github.com/cesanta/docker_auth.git \
    && cd docker_auth \
    && git checkout ${DOCKER_AUTH_REF} \
    && mv auth_server /build

WORKDIR /build

RUN make build

FROM alpine:3.19 as runtime

COPY --from=build /build/auth_server /docker_auth/
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/docker_auth/auth_server"]
CMD ["/config/auth_config.yml"]

EXPOSE 5001

