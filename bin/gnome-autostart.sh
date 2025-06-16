#!/bin/bash

source /opt/icpcbo/misc/config

if [ "$DOSETUP" = "1" ]; then
	if ! /opt/icpcbo/bin/icpcbocheckuser -q; then
		/opt/icpcbo/bin/icpcbosetup
	fi
fi
