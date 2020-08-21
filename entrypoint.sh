#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

GROUP="${GROUP:-""}"
if [ -n "${USERNAME:-""}" ]
then
	# Fix the volume permissions
	if [ -n "${VOLUMES:-""}" ]
	then
		IFS=';' read -r -a 'VOLUMES' <<< "${VOLUMES}"
		for volume in "${VOLUMES[@]}"
		do
			chown --recursive "${USERNAME}:${GROUP}" "${volume}"
		done
	fi
	
	# Set the command
	set -- gosu "${USERNAME}" 'bash' '--login' "${@}"
fi

unset 'USERNAME'
unset 'GROUP'
unset 'VOLUMES'

if [ -n "${WORKDIR:-""}" ]
then
	cd "${WORKDIR}"
	unset 'WORKDIR'
fi

exec "${@}"
