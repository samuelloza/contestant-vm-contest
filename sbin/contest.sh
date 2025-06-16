#!/bin/sh

# This needs to run as root!

contestprep()
{
	CONTESTID=$1
	# Prepare system for contest. This is run BEFORE start of contest.

	# init 3
	pkill -9 -u icpcbo

	UID=$(id -u icpcbo)
	EPASSWD=$(grep icpcbo /etc/shadow | cut -d: -f2)
	FULLNAME=$(grep ^icpcbo: /etc/passwd | cut -d: -f5 | cut -d, -f1)

	# Forces removal of home directory and mail spool
	userdel -rf icpcbo > /dev/null 2>&1

	# Remove all other user files in /tmp and /var/tmp
	find /tmp -user $UID -exec rm -rf {} \;
	find /var/tmp -user $UID -exec rm -rf {} \;

	# Recreate submissions directory
	rm -rf /opt/icpcbo/store/submissions
	mkdir /opt/icpcbo/store/submissions
	chown $UID.$UID /opt/icpcbo/store/submissions

	# Remove screenshot data
	rm /opt/icpcbo/store/screenshots/*

	/opt/icpcbo/sbin/make_icpc_bo_user.sh

	# Detect cases where the crypt password is invalid, and if so set default passwd
	if [ ${#EPASSWD} -gt 5 ]; then
		echo "icpcbo:$EPASSWD" | chpasswd -e
	else
		echo "icpcbo:icpcbo" | chpasswd
	fi

	chfn -f "$FULLNAME" icpcbo

	/opt/icpcbo/sbin/firewall.sh start
	USER=$(/opt/icpcbo/bin/icpcbocheckuser -q)
	echo "$USER" > /opt/icpcbo/run/userid.txt
	echo "$CONTESTID" > /opt/icpcbo/run/contestid.txt
	echo "$CONTESTID" > /opt/icpcbo/run/lockdown

	# init 5
}

schedule()
{
	# Remove existing jobs that were created by this script
	for i in `atq | cut -f1`; do
		if at -c $i | grep -q '# AUTO-CONTEST-SCHEDULE'; then
			atrm $i
		fi
	done

	while IFS=" " read date time cmd
	do
		cat - <<EOM | at $time $date 2> /dev/null
# AUTO-CONTEST-SCHEDULE
$cmd
EOM
		#echo $date, $time, $cmd
	done < /opt/icpcbo/misc/schedule
}

monitor()
{
	DATE=$(date +%Y%m%d%H%M%S)
	echo "$DATE monitor run" >> /opt/icpcbo/store/contest.log

	# capture screen every minute but with 50% chance
	if [ $(seq 2 | shuf | head -1) -eq 2 ]; then
		USER=$(cat /opt/icpcbo/run/userid.txt)
		sudo -u icpcbo env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u icpcbo)/bus /opt/icpcbo/sbin/take_screenshot.py \
			> /opt/icpcbo/store/screenshots/$USER-$DATE.png
	fi

	# Check if auto backups are requested
	if [ -f /opt/icpcbo/config/autobackup ]; then
		# This script runs every minute, but we want to only do backups every 5 mins
		if [ $(( $(date +%s) / 60 % 5)) -eq 0 ]; then
			# Insert a random delay up to 30 seconds so backups don't all start at the same time
			sleep $(seq 30 | shuf | head -1)
			/opt/icpcbo/bin/icpcbobackup.sh > /dev/null &
		fi
	fi
}

lock()
{
	passwd -l icpcbo
	cat - <<EOM > /etc/gdm3/greeter.dconf-defaults
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text='The contest is about to start.\nYour computer is temporarily locked.\nYou are not allowed to log in yet.\nPlease wait for further instructions.'
EOM
	systemctl restart gdm3
}

unlock()
{
	passwd -u icpcbo
	cat - <<EOM > /etc/gdm3/greeter.dconf-defaults
[org/gnome/login-screen]
banner-message-enable=false
EOM
	systemctl restart gdm3
}


logger -p local0.info "CONTEST: execute '$@'"

case "$1" in
	lock)
		lock
		;;
	unlock)
		unlock
		;;
	prep)
		contestprep $2
		unlock
		;;
	start)
		logkeys --start --keymap /opt/icpcbo/misc/en_US_ubuntu_1204.map
		echo "* * * * * root /opt/icpcbo/sbin/contest.sh monitor" > /etc/cron.d/contest
		;;
	stop)
		logkeys --kill
		rm /etc/cron.d/contest
		;;
	done)
		/opt/icpcbo/sbin/firewall.sh stop
		rm /opt/icpcbo/run/lockdown
		rm /opt/icpcbo/run/contestid.txt
		rm /opt/icpcbo/run/userid.txt
		;;
	schedule)
		schedule
		;;
	monitor)
		monitor
		;;
	*)
		;;
esac

# vim: ft=sh ts=4 noet
