# Standard Makefile for my Go repos — drop into any repo root unchanged.
# Convention: binary name = repo dir name, entrypoint at ./cmd/<binary>.

BINARY := $(notdir $(CURDIR))
CMD    := ./cmd/$(BINARY)

.PHONY: all build run test vet fmt fmt-fix gates clean

all: gates build

build:
	go build -ldflags="-s -w" -o $(BINARY) $(CMD)

run:
	go run $(CMD)

test:
	GOTOOLCHAIN=local go test ./...

vet:
	GOTOOLCHAIN=local go vet ./...

fmt:
	@test -z "$$(gofmt -l .)" || { gofmt -l .; exit 1; }

fmt-fix:
	gofmt -w .

gates: fmt vet test

clean:
	rm -f $(BINARY)
