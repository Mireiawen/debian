#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Read the command line options
TEMP="$(getopt -n 'lint' -o 'dsya' --long 'lint-docker,lint-shell,lint-yaml,lint-all' -- "${@}")"
eval set -- "${TEMP}"

# Set up the defaults
LINT_DOCKER="0"
LINT_SHELL="0"
LINT_YAML="0"

while [ ${#} -gt 0 ]
do
        case "${1}" in
        '-d' | '--lint-docker')
                LINT_DOCKER="1"
                shift
                ;;

        '-s' | '--lint-shell')
                LINT_SHELL="1"
                shift
                ;;

        '-a' | '--lint-all')
                LINT_DOCKER="1"
                LINT_SHELL="1"
		LINT_YAML="1"
                shift
                ;;

        '--')
                shift
                break
                ;;
        esac
done

# Lint all if none specified
if [ "${LINT_DOCKER}" == "0" ] \
	&& [ "${LINT_SHELL}" == "0" ] \
	&& [ "${LINT_YAML}" == "0" ]
then
	LINT_DOCKER="1"
	LINT_SHELL="1"
	LINT_YAML="1"
fi

if [ "${LINT_DOCKER}" == "1" ]
then
	hadolint \
		'Dockerfile' \
		'Dockerfile.user.j2'
fi

if [ "${LINT_SHELL}" == "1" ]
then
	shellcheck \
		'entrypoint.sh' \
		'start-container' \
		'install_pip' \
		'build.sh' \
		'lint.sh'
fi

if [ "${LINT_YAML}" == "1" ]
then
	yamllint '.'
fi
