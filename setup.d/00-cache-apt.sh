#!/bin/bash

set -x
set -e

# Only for local testing purposes
# I added this because the internet to teset is slow, so it was a good workaround

echo 'Acquire::http { Proxy "http://10.0.2.2:3142"; };' | sudo tee /etc/apt/apt.conf.d/02proxy
sudo apt-get update
