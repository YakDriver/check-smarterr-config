FROM golang:1.23-alpine3.20 AS builder

RUN apk add --no-cache git

WORKDIR /build

# Clone and build smarterr
RUN git clone https://github.com/YakDriver/smarterr.git . && \
    go mod download && \
    CGO_ENABLED=0 GOOS=linux go build -o smarterr .

# Use a minimal runtime image — pin Alpine version here too
FROM alpine:3.20

RUN apk add --no-cache findutils

# Copy only the compiled binary
COPY --from=builder /build/smarterr /usr/local/bin/smarterr
RUN chmod +x /usr/local/bin/smarterr

# Copy and prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
