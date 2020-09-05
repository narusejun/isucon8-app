PROJECT_ROOT:=/home/isucon/torb
BUILD_DIR:=/home/isucon/torb/webapp/go
BIN_NAME:=torb

all: build

.PHONY: clean
clean:
	cd $(BUILD_DIR); \
	rm -rf ${BIN_NAME}

.PHONY: deploy
deploy: build restart

.PHONY: build
build:
	git pull&& \
	cd $(BUILD_DIR); \
	GOPATH=`pwd`:`pwd`/vendor go build -v torb
	# TODO

.PHONY: restart
restart:
	sudo systemctl restart torb.go.service
