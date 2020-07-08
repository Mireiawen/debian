#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Locales to generate
LOCALES="${LOCALES:-"en_US.UTF-8 UTF-8\\nfi_FI.UTF-8 UTF-8"}"

# User information
USER="${USER:-"$(whoami)"}"
NAME="$(getent 'passwd' "${USER}" |cut --delim ':' --field '5' |cut --delim ',' --field '1')"

# Container name
CONTAINER="${CONTAINER:-"Container-${USER}"}"

# Export for Jinja2
export LOCALES
export USER
export NAME
export UID
export CONTAINER

# Build the base image
docker 'build' \
	'.' \
	--file 'Dockerfile' \
	--tag 'mireiawen/debian'

# Build the user image
j2 'Dockerfile.user.j2' |\
docker 'build' \
	'.' \
	--tag "mireiawen/debian:${USER}" \
	--file '-'
