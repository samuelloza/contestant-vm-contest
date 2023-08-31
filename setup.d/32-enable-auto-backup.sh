#!/bin/bash

set -x
set -e

# This was enabled in IOI-2022 and IOI-2023 by default
# No outage or other problems were observed during IOI 2023 (Practice Contest and Contest Day 1)
/opt/ioi/bin/ioiconf.sh setautobackup on
