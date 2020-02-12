#!/bin/bash

## install server postgres

IP=$(hostname -I | awk '{print $2}')

echo "START - install postgres - "$IP

echo "[1]: install postgres"
apt-get update -qq >/dev/null
apt-get install -qq -y vim git wget curl git >/dev/null
apt-get install -qq postgresql-11 >/dev/null
sudo -u postgres bash -c "psql -c \"CREATE USER vagrant WITH PASSWORD 'vagrant';\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE dev OWNER vagrant;\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE stage OWNER vagrant;\""
sudo -u postgres bash -c "psql -c \"CREATE DATABASE prod OWNER vagrant;\""
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/11/main/postgresql.conf
sed -i "s/127.0.0.1\/32/0.0.0.0\/0/g" /etc/postgresql/11/main/pg_hba.conf
service postgresql restart

echo "END - install postgres"

