#!/bin/bash
#
# This script expects to run as root.  It can provision a Salt Master on 
# localhost or on a remotehost.  If a remotehost is given, we will make
# two SSH connections as root.  The first connection will rsync this directory
# to /root/salt on the remotehost.  The second connection will invoke this 
# script on the remotehost.

USAGE="/bin/bash scripts/bootstrap-master.sh <NEWMASTER IP/FQDN> [NEWMASTER ID]"

NEWMASTER=$1
NEWMASTERID=$2

if [ -z "$NEWMASTER" ]
  then
    echo $USAGE
    exit 1
fi
if [ -z "$NEWMASTERID" ]
  then
    NEWMASTERID=$NEWMASTER
fi

if [ $NEWMASTER = "localhost" ]
then
  # download salt-boostrap.sh script.
  curl -o /root/salt/scripts/salt-bootstrap.sh -L http://bootstrap.saltstack.org
  # install both salt-minion and salt-master packages.
  sh /root/salt/scripts/salt-bootstrap.sh -M
  # configure salt-minion.
  cat << EOF > /etc/salt/minion.d/minion.conf
id: $NEWMASTERID
master: $NEWMASTER
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

  # run highstate to use config management to setup the rest!
  echo "Calling highstate on Salt Master ..."
  salt -l debug "$NEWMASTERID" test.ping
  salt -l debug "$NEWMASTERID" state.highstate
  echo "The Salt Master has been setup!"
  exit 0

else
  scp -rq . root@$NEWMASTER:/root/salt/
  ssh root@$NEWMASTER "bash /root/salt/scripts/bootstrap-master.sh localhost $NEWMASTERID"
fi
