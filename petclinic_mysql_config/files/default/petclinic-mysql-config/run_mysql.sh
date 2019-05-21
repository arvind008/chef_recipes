#!/bin/sh

sudo sed -i 's/bind-address = 127.0.0.1/#bind-address = 127.0.0.1/g' /etc/mysql/my.cnf

sudo service mysql restart
