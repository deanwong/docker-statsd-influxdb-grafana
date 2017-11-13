#!/bin/bash

chown -R mysql:mysql /var/lib/mysql /usr/sbin/mysqld

#ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock

echo "=> Starting MySQL ..."
/etc/init.d/mysql start

sleep 5

echo "Creating user"
echo "CREATE DATABASE grafana" | mysql --default-character-set=utf8
echo "CREATE USER '${MYSQL_GRAFANA_USER}' IDENTIFIED BY '${MYSQL_GRAFANA_PW}'" | mysql --default-character-set=utf8
echo "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_GRAFANA_USER}'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql --default-character-set=utf8

echo "=> Stopping MySQL ..."
/etc/init.d/mysql stop

exit 0