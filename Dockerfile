# Keep this toolchain at or above the Go version required by SMARTERR_VERSION.
FROM golang:1.26-alpine3.22 AS builder

# Pin the smarterr CLI version. Do not use "latest": a smarterr release that
# raises its Go directive breaks this image build for every consumer.
ARG SMARTERR_VERSION=v0.9.0

# Install smarterr CLI
RUN CGO_ENABLED=0 GOOS=linux go install github.com/YakDriver/smarterr/cmd/smarterr@${SMARTERR_VERSION}

# Use a minimal runtime image — pin Alpine version here too
FROM alpine:3.22

RUN apk add --no-cache findutils

# Copy only the compiled binary
COPY --from=builder /go/bin/smarterr /usr/local/bin/smarterr
RUN chmod +x /usr/local/bin/smarterr

# Copy and prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
