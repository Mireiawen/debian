#!/bin/bash
set -e

# Write the backports list file for current codename
echo "deb http://ftp.debian.org/debian $(lsb_release --short --codename)-backports main" \
	>'/etc/apt/sources.list.d/backports.list'

# Enable the backports list
DEBIAN_FRONTEND="noninteractive" apt-get 'update'
