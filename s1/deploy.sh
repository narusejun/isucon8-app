#!/bin/bash

sudo systemctl daemon-reload
sudo systemctl restart torb.go
sudo systemctl restart nginx
sudo systemctl restart mariadb
