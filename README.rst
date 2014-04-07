Egg
###

An attempt at solving the Chicken-and-the-egg problem.

This repo holds minimal Salt States and Public Pillar as well as some scripts
to bootstrap a new Salt cluster.  

What comes first?
=================

To start things off, we need a Salt Master.  Checkout this repo on your
workstation.  From the root of the repo, run:

    /bin/bash scripts/bootstrap-master.sh <NEWMASTER IP/FQDN> [NEWMASTER ID]

NOTE: this script expects to run as root.

NEWMASTER:
 required: must be an IP address, a FQDN, or localhost.

NEWMASTERID:
 optional: the ID of the new salt master's minion, defaults to NEWMASTER. 

If NEWMASTER is *localhost* the salt-master and salt-minion daemons will be
installed locally, and this directory will be copied to /root/salt
(the location of the Salt file_roots and pillar_roots).

If NEWMASTER is a *remote host* this script will create two SSH connections
to the remote host as root user. The first connection will SCP this directory
to remote-host:/root/salt. The second connection will fire this script off on
the remote-host.

Real world example used to stand-up a Salt Master on remote Ubuntu host:

    /bin/bash scripts/bootstrap-master.sh 162.243.113.164 master

YAY!
