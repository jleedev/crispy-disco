FROM rust:alpine AS builder
RUN apk add musl-dev

WORKDIR /build
COPY . .
RUN cargo install --path .

FROM alpine
COPY --from=builder /usr/local/cargo/bin/server /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/server"]
