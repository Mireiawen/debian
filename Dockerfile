# Source images
FROM "aquasec/trivy:latest" as trivy
FROM "bitnami/kubectl:latest" as kubectl
FROM "bitnami/minideb:buster" as minideb
FROM "docker:dind" as dind
FROM "hadolint/hadolint:latest" as hadolint
FROM "koalaman/shellcheck:stable" as shellcheck
FROM "mikefarah/yq:latest" as yq
FROM "openshift/origin-cli:latest" as origin-cli
FROM "vault:latest" as vault

FROM "debian:10"
ARG GOSU_VERSION="1.12"
ARG BORG_VERSION="1.1.16"
ARG GH_VERSION="1.7.0"
SHELL [ "/bin/bash", "-e", "-u", "-o", "pipefail", "-c" ]

# Add the labels for the image
LABEL name="debian"
LABEL summary="Customized Debian Docker image"
LABEL maintainer="Mira 'Mireiawen' Manninen"

# Install the installer script
COPY --from=minideb \
	"/usr/sbin/install_packages" \
	"/usr/sbin/install_packages"

COPY \
	"install_pip" \
	"/usr/sbin/install_pip"

# Enable the backports repository
RUN echo "deb http://ftp.debian.org/debian buster-backports main" \
	>"/etc/apt/sources.list.d/backports.list" 

# Install some basic tools for use
RUN install_packages \
		"acl" \
		"apt-transport-https" \
		"aptitude" \
		"bc" \
		"bzip2" \
		"ca-certificates" \
		"curl" \
		"dnsutils" \
		"gnupg2" \
		"htop" \
		"iotop" \
		"keychain" \
		"less" \
		"locales" \
		"lsb-release" \
		"mailutils" \
		"net-tools" \
		"netcat" \
		"ntp" \
		"procps" \
		"pwgen" \
		"sudo" \
		"unzip" \
		"vim" \
		"vim-addon-manager" \
		"wget" \
		"whois"

# Make sure we generate the locales
RUN echo "en_US.UTF-8 UTF-8" >"/etc/locale.gen" && \
	/usr/sbin/locale-gen && \
	/usr/sbin/update-locale LANG="en_US.UTF-8"

# Install gosu for a better su+exec command
RUN curl --silent --show-error \
	--location \
	--output "/usr/local/bin/gosu" \
	"https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64"

RUN chmod "a+x" \
	"/usr/local/bin/gosu"

# Install some build toolchains
RUN install_packages \
		"build-essential" \
		"software-properties-common" \
		"git" \
		"autoconf" \
		"automake" \
		"bison" \
		"debhelper" \
		"flex" \
		"libtool" \
		"jq"

# Configure sudo
COPY "sudoers" "/etc/sudoers"
RUN chmod "ug=r,o=" "/etc/sudoers"

# Install MariaDB client
RUN install_packages \
	"mariadb-client"

# Install Python3
RUN install_packages \
	"python3-pip" \
	"python3-setuptools"

# Install wheel for Python
RUN install_pip \
	"wheel"

# Docker in Docker
COPY --from=dind \
	"/usr/local/bin/docker" \
	"/usr/local/bin/docker"

COPY --from=dind \
	"/usr/local/bin/dind" \
	"/usr/local/bin/dind"

RUN groupadd \
	--gid "998" \
	"docker"

# Install Ansible CLI
RUN install_pip \
	"ansible" \
	"ansible-lint"

# Install Ansible modules
RUN install_pip \
	"dnspython" \
	"hvac" \
	"kubernetes" \
	"kubernetes-validate" \
	"openshift" \
	"ansible-modules-hashivault"

# Install KubeCtl CLI
COPY --from=kubectl \
	"/opt/bitnami/kubectl/bin/kubectl" \
	"/usr/local/bin/kubectl"

# Install OpenShift Origin CLI
COPY --from=origin-cli \
	"/usr/bin/oc" \
	"/usr/local/bin/oc"

# Install GitHub CLI
RUN curl --silent --show-error --location \
	"https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
	| tar --gunzip --extract --strip-components=1 --directory="/usr/local"

# Install Vault CLI
COPY --from=vault \
	"/bin/vault" \
	"/usr/local/bin/vault"

# Install Molecule
RUN install_pip \
	"molecule"

# Install Trivy
COPY --from=trivy \
	"/usr/local/bin/trivy" \
	"/usr/local/bin/trivy"

# Install Shellcheck
COPY --from=shellcheck \
	"/bin/shellcheck" \
	"/usr/local/bin/shellcheck"

# Install hadolint
COPY --from=hadolint \
	"/bin/hadolint" \
	"/usr/local/bin/hadolint"

# Install J2
RUN install_pip \
	"j2cli"

# Install Certbot
RUN install_pip \
	"certbot"

# Install YQ
COPY --from=yq \
	"/usr/bin/yq" \
	"/usr/local/bin/yq"

# Install gosu entrypoint
COPY \
	"entrypoint.sh" \
	"/docker-entrypoint.sh"

# Install Borg backup utility
RUN curl --silent --show-error \
	--location \
	--output "/usr/local/bin/borg" \
	"https://github.com/borgbackup/borg/releases/download/${BORG_VERSION}/borg-linux64"
RUN chown "root:root" "/usr/local/bin/borg"
RUN chmod "u=rwx,go=rx" "/usr/local/bin/borg"

RUN ln --symbolic --force \
	"/usr/local/bin/borg" \
	"/usr/local/bin/borgfs"

# Install Borgmatic backup utility
# hadolint ignore=DL3013
RUN install_pip \
	"borgmatic"

# Install s3cmd
RUN install_pip \
	"s3cmd"

# Clean up the logs
RUN find "/var/log" -type "f" |xargs truncate -s0

ENTRYPOINT [ "/bin/bash" ]
