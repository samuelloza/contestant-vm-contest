#!/bin/bash

set -x
set -e

# Set flag to run atrun.sh at first boot
touch /opt/icpcbo/misc/schedule2.txt.firstrun
