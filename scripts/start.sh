#!/bin/bash

chown -R mysql:mysql /var/lib/mysql /usr/sbin/mysqld

#ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock

mysqld --initialize-insecure --user=mysql 

echo "=> Starting MySQL ..."
/etc/init.d/mysql start

sleep 5s

output_databases=$(echo "SHOW DATABASES" | mysql --default-character-set=utf8)
if [[ $output_databases != *"grafana"* ]]; then
  echo "Creating user"
  echo "CREATE DATABASE grafana" | mysql --default-character-set=utf8
  echo "CREATE USER '${MYSQL_GRAFANA_USER}' IDENTIFIED BY '${MYSQL_GRAFANA_PW}'" | mysql --default-character-set=utf8
  echo "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_GRAFANA_USER}'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql --default-character-set=utf8
  echo "Changing debian user privileges"
  MYSQL_PWD_DEBIAN=`grep password /etc/mysql/debian.cnf | cut -d= -f2 | head -n 1 | tr -d ' '`
  echo "Password for debian-sys-maint = $MYSQL_PWD_DEBIAN"
  echo "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$MYSQL_PWD_DEBIAN'" | mysql --default-character-set=utf8
fi

sleep 1s

echo "=> Start grafana ..."
/etc/init.d/grafana-server start

echo "=> Start supervisord ..."
/usr/bin/supervisord -n