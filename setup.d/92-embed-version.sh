#!/bin/bash

set -x
set -e

# Embed version number
if [ -n "$VERSION" ] ; then
	echo "$VERSION" > /opt/icpcbo/misc/VERSION
fi
