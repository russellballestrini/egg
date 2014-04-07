#!/bin/bash
# http://bootstrap.saltstack.org
# this script assume you can log in as root on remote host.

NEWMASTER=$1

if [ -z "$NEWMASTER" ]
  then
    echo "you must pass the NEWMASTER IP or FQDN."
    exit 1
fi

ssh root@$NEWMASTER 'curl -o /tmp/salt-bootstrap.sh -L http://bootstrap.saltstack.org'
ssh root@$NEWMASTER 'sh /tmp/salt-bootstrap.sh -M'

