# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gsp android ios gsp-cross evm all test clean
.PHONY: gsp-linux gsp-linux-386 gsp-linux-amd64 gsp-linux-mips64 gsp-linux-mips64le
.PHONY: gsp-linux-arm gsp-linux-arm-5 gsp-linux-arm-6 gsp-linux-arm-7 gsp-linux-arm64
.PHONY: gsp-darwin gsp-darwin-386 gsp-darwin-amd64
.PHONY: gsp-windows gsp-windows-386 gsp-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gsp:
	build/env.sh go run build/ci.go install ./cmd/gsp
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gsp\" to launch gsp."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gsp.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gsp.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gsp-cross: gsp-linux gsp-darwin gsp-windows gsp-android gsp-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gsp-*

gsp-linux: gsp-linux-386 gsp-linux-amd64 gsp-linux-arm gsp-linux-mips64 gsp-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-*

gsp-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gsp
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep 386

gsp-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gsp
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep amd64

gsp-linux-arm: gsp-linux-arm-5 gsp-linux-arm-6 gsp-linux-arm-7 gsp-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep arm

gsp-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gsp
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep arm-5

gsp-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gsp
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep arm-6

gsp-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gsp
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep arm-7

gsp-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gsp
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep arm64

gsp-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gsp
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep mips

gsp-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gsp
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep mipsle

gsp-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gsp
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep mips64

gsp-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gsp
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gsp-linux-* | grep mips64le

gsp-darwin: gsp-darwin-386 gsp-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gsp-darwin-*

gsp-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gsp
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-darwin-* | grep 386

gsp-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gsp
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-darwin-* | grep amd64

gsp-windows: gsp-windows-386 gsp-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gsp-windows-*

gsp-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gsp
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-windows-* | grep 386

gsp-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gsp
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gsp-windows-* | grep amd64
