#!/bin/bash

# We no longer use tinc VPN
# TODO: refactor or remove this script entirely

source /opt/icpcbo/config.sh

check_ip()
{
	local IP=$1

	if expr "$IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
		return 0
	else
		return 1
	fi
}

do_config()
{
	local CONF=$1  # vpn config filepath
	local CRED=$2  # contestant credential

	if ! test -f "$CONF"; then
		echo "Can't read $CONF"
		exit 1
	fi

	WORKDIR=`mktemp -d`

	tar jxf $CONF -C $WORKDIR
	if [ $? -ne 0 ]; then
		echo "Failed to unpack $CONF"
		rm -rf $WORKDIR
		exit 1
	fi

#	rm /etc/tinc/vpn/hosts/* 2> /dev/null
#	cp $WORKDIR/vpn/hosts/* /etc/tinc/vpn/hosts/
#	cp $WORKDIR/vpn/rsa_key.* /etc/tinc/vpn/
#	cp $WORKDIR/vpn/tinc.conf /etc/tinc/vpn/
#	cp $WORKDIR/vpn/tinc-up /etc/tinc/vpn/
#	cp $WORKDIR/vpn/icpcbobackup* /opt/icpcbo/config/ssh/

	rm -r $WORKDIR
#	USERID=$(cat /etc/tinc/vpn/tinc.conf | grep Name | cut -d\  -f3)
#	chfn -f "$USERID" icpcbo

#	systemctl stop zabbix-agent 2> /dev/null
#	systemctl disable zabbix-agent 2> /dev/null

#	systemctl enable tinc@vpn 2> /dev/null
#	systemctl restart tinc@vpn
#	/opt/icpcbo/sbin/firewall.sh start

	systemctl enable zabbix-agent 2> /dev/null
	systemctl start zabbix-agent 2> /dev/null

	mkdir -p /root/.ssh && chmod 700 /root/.ssh
	ssh-keyscan $BACKUP_SERVER > /root/.ssh/known_hosts

	if [ ! -f /opt/icpcbo/run/instanceid.txt ]; then
		openssl rand 10 | base32 > /opt/icpcbo/run/instanceid.txt
	fi

	echo "${CRED%|*}" > /opt/icpcbo/run/username.txt
	echo "${CRED##*|}" > /opt/icpcbo/run/password.txt

	exit 0
}

logger -p local0.info "icpcboCONF: invoke $1"

case "$1" in
	fwstart)
#		if [ -e /opt/icpcbo/run/lockdown ]; then
#			echo Not allowed to control firewall during lockdown mode
#		else
#			/opt/icpcbo/sbin/firewall.sh start
#		fi
		;;
	fwstop)
#		if [ -e /opt/icpcbo/run/lockdown ]; then
#			echo Not allowed to control firewall during lockdown mode
#		else
#			/opt/icpcbo/sbin/firewall.sh stop
#		fi
		;;
	vpnclear)
#		if [ -e /opt/icpcbo/run/lockdown ]; then
#			echo Not allowed to control firewall during lockdown mode
#		else
#			systemctl stop tinc@vpn
#			systemctl disable tinc@vpn 2> /dev/null
#			systemctl stop zabbix-agent
#			systemctl disable zabbix-agent 2> /dev/null
#			/opt/icpcbo/sbin/firewall.sh stop
#			rm /etc/tinc/vpn/ip.conf 2> /dev/null
#			rm /etc/tinc/vpn/mask.conf 2> /dev/null
#			rm /etc/tinc/vpn/hosts/* 2> /dev/null
#			rm /etc/tinc/vpn/rsa_key.* 2> /dev/null
#			rm /etc/tinc/vpn/tinc.conf 2> /dev/null
#			rm /opt/icpcbo/config/ssh/icpcbobackup* 2> /dev/null
#			chfn -f "" icpcbo
#		fi
		;;
	vpnstart)
#		systemctl start tinc@vpn
#		/opt/icpcbo/sbin/firewall.sh start
		;;
	vpnrestart)
#		systemctl restart tinc@vpn
#		/opt/icpcbo/sbin/firewall.sh start
		;;
	vpnstatus)
#		systemctl status tinc@vpn
		;;
	setvpnproto)
#		if [ "$2" = "tcp" ]; then
#			sed -i '/^TCPOnly/ s/= no$/= yes/' /etc/tinc/vpn/tinc.conf
#			echo VPN protocol set to TCP only.
#		elif [ "$2" = "auto" ]; then
#			sed -i '/^TCPOnly/ s/= yes$/= no/' /etc/tinc/vpn/tinc.conf
#			echo VPN procotol set to auto TCP/UDP with fallback to TCP only.
#		else
#			cat - <<EOM
#Invalid argument to setvpnproto. Specify "yes" to use TCP only, or "auto"
#to allow TCP/UDP with fallback to TCP only.
#EOM
#			exit 1
#		fi
		;;
	vpnconfig)
#		do_config $2 $3
		;;
	settz)
		tz=$2
		if [ -z "$2" ]; then
			cat - <<EOM
No timezone specified. Run tzselect to learn about the valid timezones
available on this system.
EOM
			exit 1
		fi
		if [ -f "/usr/share/zoneinfo/$2" ]; then
			cat - <<EOM
Your timezone will be set to $2 at your next login.
*** Please take note that all dates and times communicated by the icpcbo 2023 ***
*** organisers will be in Europe/Budapest timezone (GMT+2), unless it is     ***
*** otherwise specified.                                                   ***
EOM
			echo "$2" > /opt/icpcbo/config/timezone
		else
			cat - <<EOM
Timezone $2 is not valid. Run tzselect to learn about the valid timezones
available on this system.
EOM
			exit 1
		fi
		;;
	setautobackup)
		if [ "$2" = "on" ]; then
			touch /opt/icpcbo/config/autobackup
			echo Auto backup enabled
		elif [ "$2" = "off" ]; then
			if [ -f /opt/icpcbo/config/autobackup ]; then
				rm /opt/icpcbo/config/autobackup
			fi
			echo Auto backup disabled
		else
			cat - <<EOM
Invalid argument to setautobackup. Specify "on" to enable automatic backup
of home directory, or "off" to disable automatic backup. You can always run
"icpcbobackup" manually to backup at any time. Backups will only include
non-hidden files less than 100KB in size.
EOM
		fi
		;;
	setscreenlock)
		if [ "$2" = "on" ]; then
			touch /opt/icpcbo/config/screenlock
			sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.screensaver lock-enabled true
			echo Screensaver lock enabled
		elif [ "$2" = "off" ]; then
			if [ -f /opt/icpcbo/config/screenlock ]; then
				rm /opt/icpcbo/config/screenlock
			fi
			sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.screensaver lock-enabled false
			echo Screensaver lock disabled
		else
			cat - <<EOM
Invalid argument to setscreenlock. Specify "on" to enable screensaver lock,
or "off" to disable screensaver lock.
EOM
		fi
		;;
	getpubkey)
#		curl -m 5 -s -f -o /opt/icpcbo/misc/id_ansible.pub "https://$POP_SERVER/ansible.pub" > /dev/null 2>&1
#		RC=$?
#		if [ ${RC} -ne 0 ]; then
#			exit ${RC}
#		fi
#		chmod 664 /opt/icpcbo/misc/id_ansible.pub
#		chown ansible:ansible /opt/icpcbo/misc/id_ansible.pub
#
#		cp /opt/icpcbo/misc/id_ansible.pub /home/ansible/.ssh/authorized_keys
#		chmod 600 /home/ansible/.ssh/authorized_keys
#		chown ansible:ansible /home/ansible/.ssh/authorized_keys
#		exit 0
		;;
	keyscan)
		mkdir -p /root/.ssh
#		ssh-keyscan -H ${BACKUP_SERVER} > /root/.ssh/known_hosts 2> /dev/null
		chmod 600 /root/.ssh/known_hosts
		;;
	*)
		echo Not allowed
		;;
esac

# vim: ft=sh ts=4 sw=4 noet
