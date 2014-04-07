#!/bin/bash
#
# This script expects to run as root. It may be used to provision a Salt
# Master on remote or localhost. If a remote host is given, we will make
# two SSH connections as root. The first connection will scp this directory
# to /root/salt on the remote host. The second connection will invoke this 
# script on the remote host.

USAGE="/bin/bash scripts/bootstrap-master.sh <NEWMASTER IP/FQDN> [NEWMASTER ID]"

NEWMASTER=$1
NEWMASTERID=$2

if [ -z "$NEWMASTER" ]; then
  echo $USAGE; exit 1;
fi

if [ -z "$NEWMASTERID" ]; then
  NEWMASTERID=$NEWMASTER
fi

if ! [ $NEWMASTER = "localhost" ]; then
  scp -rq . root@$NEWMASTER:/root/salt/
  ssh root@$NEWMASTER "bash /root/salt/scripts/bootstrap-master.sh localhost $NEWMASTERID"
else
  # download salt-boostrap.sh script and install salt-minion and salt-master.
  curl -o /root/salt/scripts/salt-bootstrap.sh -L http://bootstrap.saltstack.org
  sh /root/salt/scripts/salt-bootstrap.sh -M
  # configure salt-minion.
  cat << EOF > /etc/salt/minion.d/minion.conf
id: $NEWMASTERID
master: $NEWMASTER
grains:
  roles:
    - salt-master
EOF
  # configure salt-master. centos doesn't have /etc/salt/master.d?
  #cat << EOF > /etc/salt/master.d/master.conf
  cat << EOF > /etc/salt/master
file_roots:
  base:
    - /root/salt/states

pillar_roots:
  base:
    - /root/salt/pillar-public
EOF
  # reload salt-master so new configuration is loaded.
  service salt-master restart
  # reload salt-minion so new configuration is loaded.
  service salt-minion restart

  # loop NEWMASTERID appears in salt-key or exit script after timeout.
  TIMEOUT=90
  COUNT=0
  while ! [ $(salt-key -L | grep -m 1 "$NEWMASTERID") ]; do
      echo "Waiting for $NEWMASTERID key to appear."
      if [ "$COUNT" -ge "$TIMEOUT" ]; then
          echo "Timeout while waiting for $NEWMASTERID key to appear."
          exit 1
      fi
      sleep 3
      COUNT=$((COUNT+3))
  done

  # make the salt-master auto-accept its own public key.
  salt-key --yes --accept $NEWMASTERID

  # run highstate, config management will setup the rest!
  echo "Calling highstate on Salt Master ..."
  salt -l debug "$NEWMASTERID" test.ping
  salt -l debug "$NEWMASTERID" state.highstate
  echo "The Salt Master has been setup!"
  exit 0
fi
