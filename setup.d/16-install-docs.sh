#!/bin/bash

set -x
set -e

# Documentation

apt -y install python3-doc

# CPP Reference

$wget https://github.com/PeterFeicht/cppreference-doc/releases/download/v20250209/html-book-20250209.zip
mkdir -p /usr/share/doc/cppreference
unzip -o $cache/html-book-20250209.zip -d /usr/share/doc/cppreference
