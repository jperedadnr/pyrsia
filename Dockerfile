# syntax=docker/dockerfile:1.4.1

FROM rust:1.62-buster AS builder
ENV CARGO_TARGET_DIR=/target
WORKDIR /src
RUN apt-get update && apt-get install -y \
    clang \
    libclang-dev \
    cmake

FROM builder AS debug
COPY . .

FROM builder AS dupdatelock
COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/usr/local/cargo/registry/cache \
    --mount=type=cache,target=/usr/local/cargo/registry/index \
    cargo update

FROM scratch AS updatelock
COPY --from=dupdatelock /src/Cargo.lock .

FROM builder AS dbuild
RUN mkdir -p /out
ENV RUST_BACKTRACE=1
ENV DEV_MODE=on
ENV PYRSIA_ARTIFACT_PATH=pyrsia
ENV PYRSIA_BLOCKCHAIN_PATH=pyrsia/blockchain
RUN --mount=target=/src \
    --mount=type=cache,target=/target \
    --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/usr/local/cargo/registry/cache \
    --mount=type=cache,target=/usr/local/cargo/registry/index \
    cargo build --profile=release --package=pyrsia_node && cp /target/release/pyrsia_node /out/

FROM debian:buster-slim AS node

ENV RUST_LOG=info
RUN <<EOT bash
    set -e
    apt-get update
    apt-get install -y \
        ca-certificates jq curl
    rm -rf /var/lib/apt/lists/*
EOT
COPY --from=dbuild /out/pyrsia_node /usr/bin/

COPY installers/docker/node-entrypoint.sh /tmp/entrypoint.sh
RUN chmod 755 /tmp/entrypoint.sh; mkdir -p /usr/local/var/pyrsia

WORKDIR /usr/local/var

ENV PYRSIA_ARTIFACT_PATH /usr/local/var/pyrsia
ENV PYRSIA_BLOCKCHAIN_PATH /usr/local/var/pyrsia/blockchain
ENV RUST_LOG debug
