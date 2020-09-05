PROJECT_ROOT:=/home/isucon/torb
BUILD_DIR:=/home/isucon/torb/webapp/go
BIN_NAME:=torb
BIN_PATH:=/home/isucon/torb/webapp/go/torb
SERVICE_NAME:=torb.go
APP_LOCAL_URL:=http://localhost:8080

NGX_SERVICE=nginx
NGX_LOG:=/var/log/nginx/access.log

MYSQL_SERVICE=mariadb
MYSQL_LOG:=/var/log/mariadb/mariadb.log

all: build

.PHONY: clean
clean:
	cd $(BUILD_DIR); \
	rm -rf ${BIN_NAME}

.PHONY: deploy
deploy: build config-files start

.PHONY: build
build:
	git pull&& \
	cd $(BUILD_DIR); \
	GOPATH=`pwd`:`pwd`/vendor go build -v torb
	# TODO

.PHONY: config-files
config-files:
	sudo rsync -r $(HOSTNAME)/ /

.PHONY: restart
restart:
	sh $(HOSTNAME)/deploy.sh

.PHONY: pprof
pprof:
	pprof -png -output /tmp/pprof.png $(BIN_PATH) $(APP_LOCAL_URL)/debug/pprof/profile
	slackcat /tmp/pprof.png
	pprof -http=0.0.0.0:9090 $(BIN_PATH) `ls -lt $(HOME)/pprof/* | head -n 1 | gawk '{print $$9}'`

.PHONY: kataru
kataru:
	sudo cat $(NGX_LOG) | kataribe -f /etc/kataribe.toml | slackcat

.PHONY: before
before:
	$(eval when := $(shell date "+%s"))
	mkdir -p ~/logs/$(when)
	sudo mv -f $(NGX_LOG) ~/logs/$(when)/
	sudo mv -f $(MYSQL_LOG) ~/logs/$(when)/
	sudo systemctl restart $(NGX_SERVICE)
	sudo systemctl restart $(MYSQL_SERVICE)
