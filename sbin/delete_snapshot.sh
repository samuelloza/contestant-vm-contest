#!/bin/bash

set -e

# https://stackoverflow.com/a/29436423
function yes_or_no {
    read -p "$* [y/N]: " yn
    case $yn in
        [Yy]*) return 0  ;;
        *) echo "Aborted" ; return  1 ;;
    esac
}

yes_or_no "Do you really want to delete the snapshot?" && mkfs.ext4 /dev/nvme0n1p3
