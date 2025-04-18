#!/bin/bash

# - Installs required packages including Zabbix Agent 2
# - Modifies the Zabbix systemd unit to use a custom configuration file
# - Creates a custom Zabbix agent configuration with tailored monitoring items
# - Defines UserParameters to check processes and logs
# - Reloads systemd and sets up the Zabbix Agent service

set -x
set -e

apt -y install net-tools openssh-server ansible xvfb oathtool imagemagick zabbix-agent2

sed -i 's|/etc/zabbix/zabbix_agent2.conf|/etc/zabbix/zabbix_agent2_ioi.conf|' /usr/lib/systemd/system/zabbix-agent2.service

cat > /etc/zabbix/zabbix_agent2_ioi.conf <<EOF
PidFile=/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=staticsvm.ioi2025.bo
ServerActive=staticsvm.ioi2025.bo
HostnameItem=system.hostname
Include=/etc/zabbix/zabbix_agent2.d/*.conf
UnsafeUserParameters=1
EOF

mkdir -p /etc/zabbix/zabbix_agent2.d
cat > /etc/zabbix/zabbix_agent2.d/ioi_custom.conf <<EOF
# Check if a process is running
UserParameter=proc.exists[*],pgrep -x "\$1" > /dev/null && echo 1 || echo 0

# Get process elapsed time in seconds
UserParameter=proc.etime[*],ps -eo comm,etime | grep -w "\$1" | awk '{split(\$2, t, "[:-]"); if(length(t)==3){print t[1]*3600 + t[2]*60 + t[3]} else if(length(t)==2){print t[1]*60 + t[2]} else{print t[1]}}'

# Count syslog errors in the last 10 minutes
UserParameter=log.errors,grep -i error /var/log/syslog | tail -n 100 | wc -l
EOF

systemctl daemon-reexec
systemctl daemon-reload

systemctl enable zabbix-agent2
systemctl stop zabbix-agent2
