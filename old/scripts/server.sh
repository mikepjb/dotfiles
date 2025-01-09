#!/bin/sh
#
# Server Setup
# 
# When setting up a server, we typically want to contain our apps using docker & docker compose to
# abstract ourselves from the running platform. This allows us more freedom to move between any
# platform that supports docker while also keeping the number of tools we use to a minimum.

set +e

command -v docker || echo 'please install docker' && exit 1
command -v docker-compose || echo 'please install docker-compose' && exit 1

useradd -m -d /home/app -s /bin/bash -G docker app
mkdir -p /home/app/.ssh
cp /root/.ssh/authorized_keys /home/app/.ssh/authorized_keys
chown -R app:app /home/app
ufw allow proto tcp from any to any port 80,443
ufw allow ssh
ufw reload
ufw status

echo 'please install psql (ubuntu/debian package: postgresql-client-common)'
