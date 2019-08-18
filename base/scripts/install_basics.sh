#!/bin/bash -eux

# https://github.com/elastic/elasticsearch/blob/master/distribution/docker/src/docker/Dockerfile#L32
PACKAGE_NAME="kibana"

if [ -x "$(command -v apt-get)" ]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get upgrade -yq
    apt-get install -yq aptitude software-properties-common python-minimal \
      apt-transport-https nano curl wget git gnupg2 tar gzip
    python --version
elif [ -x "$(command -v dnf)" ]; then
    dnf makecache
    dnf --assumeyes install which nano curl wget git gnupg2 initscripts \
        hostname python3 tar gzip
    dnf clean all
    alternatives --set python /usr/bin/python3
    python --version
elif [ -x "$(command -v yum)" ]; then
    yum makecache fast
    yum update -y
    yum install -y which nano curl wget git gnupg2 initscripts hostname gzip \
        tar gzip shadow-utils
    yum clean all
    python --version
fi

# create system users and folders
groupadd --gid 1000 $PACKAGE_NAME
useradd -M --uid 1000 \
    --gid 1000 \
    --home-dir /usr/share/$PACKAGE_NAME \
    --shell /bin/bash $PACKAGE_NAME
mkdir -p /usr/share/$PACKAGE_NAME
cd /usr/share/$PACKAGE_NAME
mkdir -pv config data logs
chmod 0755 config data logs
chgrp 0 /usr/share/$PACKAGE_NAME

# set folder permissions
mkdir -p /var/log/$PACKAGE_NAME
chown -R root:$PACKAGE_NAME /var/log/$PACKAGE_NAME
chmod -R 0770 /var/log/$PACKAGE_NAME

mkdir -p /var/lib/$PACKAGE_NAME
chown -R root:$PACKAGE_NAME /var/lib/$PACKAGE_NAME
chmod -R 0770 /var/lib/$PACKAGE_NAME

chown -R root:$PACKAGE_NAME /usr/share/$PACKAGE_NAME
chmod -R 0775 /usr/share/$PACKAGE_NAME

# install the systemctl stub
cd /tmp
curl -sLO https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py \
  && yes | cp -f systemctl.py /usr/bin/systemctl \
  && chmod a+x /usr/bin/systemctl

# configure the docker CMD
touch /usr/local/bin/docker-entrypoint
ln -s /usr/local/bin/docker-entrypoint /usr/local/bin/kibana-docker
