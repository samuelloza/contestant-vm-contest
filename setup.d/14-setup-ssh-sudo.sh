#!/bin/bash

set -x
set -e

# Setup empty SSH authorized keys and passwordless sudo for ansible

mkdir -p ~ansible/.ssh
touch ~ansible/.ssh/authorized_keys
chown -R ansible.ansible ~ansible/.ssh

sed -i '/%sudo/ s/ALL$/NOPASSWD:ALL/' /etc/sudoers
rm /etc/sudoers.d/01-icpcbo || true
echo "icpcbo ALL=NOPASSWD: /opt/icpcbo/bin/icpcboconf.sh, /opt/icpcbo/bin/icpcboexec.sh, /opt/icpcbo/bin/icpcbobackup.sh" >> /etc/sudoers.d/01-icpcbo
echo "zabbix ALL=NOPASSWD: /opt/icpcbo/sbin/genkey.sh" >> /etc/sudoers.d/01-icpcbo
chmod 440 /etc/sudoers.d/01-icpcbo

# Deny icpcbo user from SSH login
# Wrapped in "if" to make script reentrant
if ! grep -s 'DenyUsers icpcbo' /etc/ssh/sshd_config
then
echo "DenyUsers icpcbo" >> /etc/ssh/sshd_config
fi
