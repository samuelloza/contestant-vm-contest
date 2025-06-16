#!/bin/bash

source /opt/icpcbo/config.sh

QUIET=0
MODE=backup

while [[ $# -gt 0 ]]; do
	case $1 in
		-r)
			MODE=restore
			shift
			;;
	esac
done

if [ -f /opt/icpcbo/run/icpcbobackup.pid ]; then
	if ps -p "$(cat /opt/icpcbo/run/icpcbobackup.pid)" > /dev/null; then
		echo Already running
		exit 1
	fi
fi
echo $$ >> /opt/icpcbo/run/icpcbobackup.pid

logger -p local0.info "icpcboBACKUP: invoke with mode=$MODE"

if [ "$MODE" = "backup" ]; then
	cat - <<EOM
Backing up home directory. Only non-hidden files up to a maximum of 100 KB
in size will be backed up.
EOM
	rsync -e "ssh -i /opt/icpcbo/config/ssh/icpcbobackup" \
		-avz --delete \
		--max-size=100K --bwlimit=1000 --exclude='.*' --exclude='*.pdf' ~icpcbo/ icpcbobackup@${BACKUP_SERVER}:
elif [ "$MODE" = "restore" ]; then
	echo Restoring into /tmp/restore.
	if [ -e /tmp/restore ]; then
		cat - <<EOM
Error: Unable to restore because /tmp/restore already exist. Remove or move
away the existing file or directory before running again.
EOM
	else
		rsync -e "ssh -i /opt/icpcbo/config/ssh/icpcbobackup" \
    		    -avz --max-size=100K --bwlimit=1000 --exclude='.*' \
				icpcbobackup@${BACKUP_SERVER}: /tmp/restore
		chown icpcbo:icpcbo -R /tmp/restore
	fi
fi


rm /opt/icpcbo/run/icpcbobackup.pid

# vim: ft=bash ts=4 noet
