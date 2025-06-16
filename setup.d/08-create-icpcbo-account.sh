#!/bin/bash

set -x
set -e

# Create icpcbo account
/opt/icpcbo/sbin/make_icpc_bo_user.sh

# Set icpcbo user's initial password
echo "icpcbo:icpcbo" | chpasswd

# Fix permission and ownership
chown icpcbo:icpcbo /opt/icpcbo/store/submissions
chown ansible:syslog /opt/icpcbo/store/log
chmod 770 /opt/icpcbo/store/log
