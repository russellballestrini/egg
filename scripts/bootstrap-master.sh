#!/bin/bash
#
# This script expects to run as root.  It can provision a Salt Master on 
# localhost or on a remotehost.  If a remotehost is given, we will make
# two SSH connections as root.  The first connection will rsync this directory
# to /root/salt on the remotehost.  The second connection will invoke this 
# script on the remotehost.

NEWMASTER=$1

if [ -z "$NEWMASTER" ]
  then
    echo "you must pass the NEWMASTER IP or FQDN."
    exit 1
fi


if [ $NEWMASTER = "localhost" ]
then
  curl -o /root/salt/scripts/salt-bootstrap.sh -L http://bootstrap.saltstack.org
  sh /root/salt/scripts/salt-bootstrap.sh -M
  cat << EOF > /etc/salt/master.d/master.conf

master: localhost

file_roots:
  base:
    - /root/salt/states

pillar_roots:
  base:
    - /root/salt/pillar-public

EOF
  service salt-master restart
  service salt-minion restart
  salt-key -A
  salt '*' state.highstate
else
  rsync -a . root@$NEWMASTER:/root/salt/
  ssh root@$NEWMASTER 'bash /root/salt/scripts/bootstrap-master.sh localhost'
fi
