#!/bin/bash

set -x
set -e

systemctl mask udisks2
systemctl stop udisks2
