#!/bin/sh

# We no longer use the schedule
# TODO: refactor or remove this script entirely

# PARTKEY=$(/opt/icpcbo/sbin/genkey.sh)

# if [ $# -lt 2 ]; then
# 	echo "Too few arguments" >&2
# 	exit 1
# fi

# TOTP=$1

# shift 1

# CMDSTRING=$*

# FULLKEY=$(echo $PARTKEY $CMDSTRING | sha256sum | cut -d\  -f1)

# logger -p local0.info "icpcboEXEC: invoke '$CMDSTRING'"

# totp interval set to 30 minutes
# if ! oathtool -s 1800 --totp $FULLKEY -d 8 -w 1 -- "$TOTP" > /dev/null 2>&1; then
# 	echo "TOTP failed" >&2
# 	logger -p local0.info "icpcboEXEC: totp failed"
# 	exit;
# fi

# case $1 in
# 	fwstop)
# 		systemctl stop tinc@vpn
# 		iptables -P OUTPUT ACCEPT
# 		iptables -P INPUT ACCEPT
# 		iptables -F
# 		logger -p local0.info "icpcboEXEC: firewall stopped"
# 		;;
# 	vpnclear)
# 		systemctl stop tinc@vpn
# 		systemctl disable tinc@vpn 2> /dev/null
# 		rm /etc/tinc/vpn/ip.conf 2> /dev/null
# 		rm /etc/tinc/vpn/mask.conf 2> /dev/null
# 		rm /etc/tinc/vpn/dns.conf 2> /dev/null
# 		rm /etc/tinc/vpn/hosts/* 2> /dev/null
# 		rm /etc/tinc/vpn/rsa_key.* 2> /dev/null
# 		rm /etc/tinc/vpn/tinc.conf 2> /dev/null
# 		rm /opt/icpcbo/config/ssh/icpcbobackup* 2> /dev/null
# 		logger -p local0.info "icpcboEXEC: vpn stopped"
# 		chfn -f "icpcbo Contestant" icpcbo
# 		echo "Due to some issues, we have disabled VPN connection to CMS."
# 		echo ""
# 		echo "For now, open https://cms-public.nonexistent on Firefox,"
# 		echo "and log in using the following credentials:"
# 		echo ""
# 		echo "- Username: $(cat /opt/icpcbo/run/username.txt)"
# 		echo "- Password: $(cat /opt/icpcbo/run/password.txt)"
# 		;;
# esac

# vim: ft=sh ts=4 noet
