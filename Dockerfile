# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /duck-ddns ./cmd/duck-ddns

# Runtime stage
FROM alpine:3.21

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /duck-ddns /usr/local/bin/duck-ddns

# Mount your config at /config, or pass a different path as the container command argument
ENTRYPOINT ["duck-ddns"]
CMD ["/config/duck-ddns.json"]
