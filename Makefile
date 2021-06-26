.PHONY: jknetwork android ios jknetwork-cross swarm evm all test clean
.PHONY: jknetwork-linux jknetwork-linux-386 jknetwork-linux-amd64 jknetwork-linux-mips64 jknetwork-linux-mips64le
.PHONY: jknetwork-linux-arm jknetwork-linux-arm-5 jknetwork-linux-arm-6 jknetwork-linux-arm-7 jknetwork-linux-arm64
.PHONY: jknetwork-darwin jknetwork-darwin-386 jknetwork-darwin-amd64
.PHONY: jknetwork-windows jknetwork-windows-386 jknetwork-windows-amd64
.PHONY: docker release

GOBIN = $(shell pwd)/build/bin
GO ?= latest

# Compare current go version to minimum required version. Exit with \
# error message if current version is older than required version.
# Set min_ver to the mininum required Go version such as "1.12"
min_ver := 1.12
ver = $(shell go version)
ver2 = $(word 3, ,$(ver))
cur_ver = $(subst go,,$(ver2))
ver_check := $(filter $(min_ver),$(firstword $(sort $(cur_ver) \
$(min_ver))))
ifeq ($(ver_check),)
$(error Running Go version $(cur_ver). Need $(min_ver) or higher. Please upgrade Go version)
endif

jknetwork:
	cd cmd/jknetwork; go build -o ../../bin/jknetwork
	@echo "Done building."
	@echo "Run \"bin/jknetwork\" to launch jknetwork."

bootnode:
	cd cmd/bootnode; go build -o ../../bin/jknetwork-bootnode
	@echo "Done building."
	@echo "Run \"bin/jknetwork-bootnode\" to launch jknetwork."

docker:
	docker build -t jknetwork/jknetwork .

all: bootnode jknetwork

release:
	./release.sh

install: all
	cp bin/jknetwork-bootnode $(GOPATH)/bin/jknetwork-bootnode
	cp bin/jknetwork $(GOPATH)/bin/jknetwork

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/jknetwork.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/jknetwork.framework\" to use the library."

test:
	go test ./...

clean:
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

jknetwork-cross: jknetwork-linux jknetwork-darwin jknetwork-windows jknetwork-android jknetwork-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-*

jknetwork-linux: jknetwork-linux-386 jknetwork-linux-amd64 jknetwork-linux-arm jknetwork-linux-mips64 jknetwork-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-*

jknetwork-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/jknetwork
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep 386

jknetwork-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/jknetwork
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep amd64

jknetwork-linux-arm: jknetwork-linux-arm-5 jknetwork-linux-arm-6 jknetwork-linux-arm-7 jknetwork-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep arm

jknetwork-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/jknetwork
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep arm-5

jknetwork-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/jknetwork
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep arm-6

jknetwork-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/jknetwork
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep arm-7

jknetwork-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/jknetwork
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep arm64

jknetwork-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/jknetwork
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep mips

jknetwork-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/jknetwork
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep mipsle

jknetwork-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/jknetwork
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep mips64

jknetwork-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/jknetwork
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-linux-* | grep mips64le

jknetwork-darwin: jknetwork-darwin-386 jknetwork-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-darwin-*

jknetwork-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/jknetwork
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-darwin-* | grep 386

jknetwork-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/jknetwork
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-darwin-* | grep amd64

jknetwork-windows: jknetwork-windows-386 jknetwork-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-windows-*

jknetwork-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/jknetwork
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-windows-* | grep 386

jknetwork-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/jknetwork
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/jknetwork-windows-* | grep amd64
