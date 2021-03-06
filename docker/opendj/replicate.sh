#!/usr/bin/env sh
#
# Copyright (c) 2016-2017 ForgeRock AS. Use of this source code is subject to the
# Common Development and Distribution License (CDDL) that can be found in the LICENSE file
#
# Replicate to the master server hostname defined in $1.

MASTER=$1

# The hostname has to be a fully resolvable DNS name in the cluster
# if the service is called.
MYHOSTNAME=`hostname -f`


# Kubernetes puts the service name in /etc/hosts
if grep ${MASTER} /etc/hosts; then
 echo "We are the master. Skipping replication setup to ourselves."
 exit 0
fi

echo "Setting up replication from $MYHOSTNAME to $MASTER"


# todo: Replace with command to test for master being reachable and up:
echo "Will sleep for a bit to ensure master is up."
sleep 10

bin/dsreplication configure --host1 $MYHOSTNAME --port1 4444 \
  --bindDN1 "cn=directory manager" \
  --bindPassword1 $PASSWORD --replicationPort1 8989 \
  --host2 $MASTER --port2 4444 --bindDN2 "cn=directory manager" \
  --bindPassword2 $PASSWORD --replicationPort2 8989 \
  --adminUID admin --adminPassword $PASSWORD --baseDN $BASE_DN -X -n

echo "Initializing replication."

bin/dsreplication initialize --baseDN $BASE_DN \
  --adminUID admin --adminPassword $PASSWORD \
  --hostSource $MASTER --portSource 4444 \
  --hostDestination $MYHOSTNAME --portDestination 4444 -X -n

