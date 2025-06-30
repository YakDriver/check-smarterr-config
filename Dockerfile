FROM golang:1.23-alpine3.20 AS builder

# Accept smarterr version as build argument
ARG SMARTERR_VERSION="v0.6.0"

# Install smarterr CLI
RUN CGO_ENABLED=0 GOOS=linux go install github.com/YakDriver/smarterr/cmd/smarterr@${SMARTERR_VERSION}

# Use a minimal runtime image — pin Alpine version here too
FROM alpine:3.20

RUN apk add --no-cache findutils

# Copy only the compiled binary
COPY --from=builder /go/bin/smarterr /usr/local/bin/smarterr
RUN chmod +x /usr/local/bin/smarterr

# Copy and prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
