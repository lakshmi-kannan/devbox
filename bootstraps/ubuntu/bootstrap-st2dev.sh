#!/usr/bin/env bash

if [ `uname` != "Linux" ]; then
    echo "ERROR: bootstrap.sh is only supported on a Linux system."
    exit 1
fi

ST2KIT="libffi-dev libssl-dev libpq-dev"
SERVICES="rabbitmq-server postgresql apache2-utils nginx"

apt-get -y install ${ST2KIT} ${SERVICES}

# Setup rabbitmqadmin
rabbitmq-plugins enable rabbitmq_management
service rabbitmq-server restart
curl -sS -o /usr/bin/rabbitmqadmin http://127.0.0.1:15672/cli/rabbitmqadmin
chmod 755 /usr/bin/rabbitmqadmin

# MongoDB 3.2
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get -y update
apt-get install -y mongodb-org

# StackStorm SSH system user
useradd stanley
mkdir -p /home/stanley/.ssh
chmod 0700 /home/stanley/.ssh
ssh-keygen -f /home/stanley/.ssh/stanley_rsa -P ""
sh -c 'cat /home/stanley/.ssh/stanley_rsa.pub >> /home/stanley/.ssh/authorized_keys'
chmod 0600 /home/stanley/.ssh/authorized_keys
chown -R stanley:stanley /home/stanley
sh -c 'echo "stanley    ALL=(ALL)       NOPASSWD: SETENV: ALL" >> /etc/sudoers.d/st2'
chmod 0440 /etc/sudoers.d/st2
cp /home/stanley/.ssh/stanley_rsa /home/vagrant/.ssh/stanley_rsa
chown vagrant:vagrant /home/vagrant/.ssh/stanley_rsa
