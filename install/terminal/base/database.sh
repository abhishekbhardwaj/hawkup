#!/bin/bash

# Install SQLite (commonly needed regardless of selection)
sudo apt install -y sqlite3 libsqlite3-0

# Process database selections
IFS=',' read -ra DBS <<< "$HAWKUP_FIRST_RUN_DBS"
for db in "${DBS[@]}"; do
	case $db in
	Redis)
		echo "Setting up Redis..."
		sudo apt install -y redis-tools
		sudo docker run -d --restart unless-stopped -p "127.0.0.1:6379:6379" --name=redis redis:7
		;;
	MySQL)
		echo "Setting up MySQL..."
		sudo apt install -y libmysqlclient-dev
		sudo docker run -d --restart unless-stopped -p "127.0.0.1:3306:3306" --name=mysql8 -e MYSQL_ROOT_PASSWORD= -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql:8.4
		;;
	PostgreSQL)
		echo "Setting up PostgreSQL..."
		sudo apt install -y libpq-dev postgresql-client postgresql-client-common
		sudo docker run -d --restart unless-stopped -p "127.0.0.1:5432:5432" --name=postgres16 -e POSTGRES_HOST_AUTH_METHOD=trust postgres:16
		;;
	esac
done
