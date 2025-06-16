#!/bin/bash

set -x
set -e

cat <<EOM >>/etc/hosts
172.16.1.1 cms.icpcbo2025.bo
172.16.2.1 backup.icpcbo2025.bo
EOM

sudo resolvectl flush-caches
