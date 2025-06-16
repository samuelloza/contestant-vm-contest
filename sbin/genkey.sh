#!/bin/sh

logger -p local0.info "GENKEY: invoked"

(cat /etc/sudoers /etc/sudoers.d/* /opt/icpcbo/misc/VERSION; \
	grep -v icpcbo /etc/passwd; \
	grep -v icpcbo /etc/shadow ) \
	| sha256sum | cut -d\  -f1
