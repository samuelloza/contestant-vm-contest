#!/bin/bash

set -x
set -e

# Install zabbix repo
$wget -O "$cache/zabbix-release_all.deb" "https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb"
dpkg -i $cache/zabbix-release_all.deb
