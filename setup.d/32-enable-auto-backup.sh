#!/bin/bash

set -x
set -e

# This was enabled in icpcbo-2022 and icpcbo-2023 by default
# No outage or other problems were observed during icpcbo 2023 (Practice Contest and Contest Day 1)
/opt/icpcbo/bin/icpcboconf.sh setautobackup on
