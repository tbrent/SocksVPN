#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or sudo" 1>&2
   exit 1
fi

echo "Stopping and removing existing proxy"
docker stop socksvpn
docker rm socksvpn
echo "Building socksvpnproxy"
docker build . -t socksvpn
echo ""
echo ""
echo "Starting socksvpnproxy"
docker run -d -P --name socksvpn --privileged socksvpn
echo ""
DPORT=$(docker port socksvpn 22 |cut -d':' -f2)

sudo lsof -i -P -n | grep "8181 (LISTEN)"

echo "Docker socksvpn ssh running on port $DPORT"
echo "Creating local socks proxy to *:8181"
echo ""
sshpass -proot ssh -p $DPORT -oStrictHostKeyChecking=no -N -M -D*:8181 root@127.0.0.1
