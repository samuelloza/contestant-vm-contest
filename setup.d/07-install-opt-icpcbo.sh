#!/bin/bash

set -x
set -e

# Copy icpcbo stuffs into /opt

mkdir -p /opt/icpcbo
cp -a bin sbin misc /opt/icpcbo/
cp config.sh /opt/icpcbo/
mkdir -p /opt/icpcbo/run
mkdir -p /opt/icpcbo/store
mkdir -p /opt/icpcbo/config
mkdir -p /opt/icpcbo/store/log
mkdir -p /opt/icpcbo/store/screenshots
mkdir -p /opt/icpcbo/store/submissions
mkdir -p /opt/icpcbo/config/ssh

# Add default timezone
echo "America/La_Paz" > /opt/icpcbo/config/timezone

# Default to enable screensaver lock
touch /opt/icpcbo/config/screenlock
