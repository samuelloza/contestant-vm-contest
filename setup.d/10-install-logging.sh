#!/bin/bash

set -x
set -e

# Add our own syslog facility

echo "local0.* /opt/icpcbo/store/log/local.log" >> /etc/rsyslog.d/10-icpcbo.conf
