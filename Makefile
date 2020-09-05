PROJECT_ROOT:=/home/isucon/torb
BUILD_DIR:=/home/isucon/torb/webapp/go
BIN_NAME:=torb
BIN_PATH:=/home/isucon/torb/webapp/go/torb
SERVICE_NAME:=torb.go
APP_LOCAL_URL:=http://localhost:8080

NGX_LOG:=/var/log/nginx/access.log
MYSQL_LOG:=/var/log/mariadb/mariadb.log

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

.PHONY: pprof
pprof:
	pprof -png -output /tmp/pprof.png $(BIN_PATH) $(APP_LOCAL_URL)/debug/pprof/profile
	slackcat /tmp/pprof.png
	pprof -http=0.0.0.0:9090 $(BIN_PATH) `ls -lt $(HOME)/pprof/* | head -n 1 | gawk '{print $$9}'`

.PHONY: kataru
kataru:
	sudo cat /var/log/nginx/access.log | kataribe -f /etc/kataribe.toml | slackcat

.PHONY: before
before:
	$(eval when := $(shell date "+%s"))
	mkdir -p ~/logs/$(when)
	@if [ -f $(NGX_LOG) ]; then \
		sudo mv -f $(NGX_LOG) ~/logs/$(when)/ ; \
	fi
	@if [ -f $(MYSQL_LOG) ]; then \
		sudo mv -f $(MYSQL_LOG) ~/logs/$(when)/ ; \
	fi
	sudo systemctl restart nginx
	sudo systemctl restart mysql
