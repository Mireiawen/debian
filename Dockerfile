FROM "debian:10"

# Add the labels for the image
LABEL name="debian"
LABEL summary="Customized Debian Docker image"
LABEL maintainer="Mira 'Mireiawen' Manninen"

# Install the installer script
COPY \
	"install_packages" \
	"/usr/sbin/install_packages"
RUN chmod "+x" "/usr/sbin/install_packages"

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
		"pwgen" \
		"unzip" \
		"vim" \
		"vim-addon-manager" \
		"wget"

# Make sure we generate the locales
RUN	echo "en_US.UTF-8 UTF-8" >"/etc/locale.gen" && \
	/usr/sbin/locale-gen && \
	/usr/sbin/update-locale LANG="en_US.UTF-8"

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

# Install Python3
RUN install_packages \
	"python3-pip" \
	"python3-setuptools"

# Install Ansible CLI
RUN pip3 install --system \
	"ansible" \
	"ansible-lint"

# Install KubeCtl CLI
COPY --from="bitnami/kubectl:latest" \
	"/opt/bitnami/kubectl/bin/kubectl" \
	"/usr/local/bin/kubectl"

# Install OpenShift Origin CLI
COPY --from="openshift/origin-cli:latest" \
	"/usr/bin/oc" \
	"/usr/local/bin/oc"

# Install Vault CLI
COPY --from="vault:latest" \
	"/bin/vault" \
	"/usr/local/bin/vault"

# Install Molecule
RUN pip3 install --system \
	"molecule"

# Install Trivy
COPY --from="aquasec/trivy:latest" \
	"/usr/local/bin/trivy" \
	"/usr/local/bin/trivy"

# Install Shellcheck
COPY --from="koalaman/shellcheck:stable" \
	"/bin/shellcheck" \
	"/usr/local/bin/shellcheck"

# Install YQ
COPY --from="mikefarah/yq" \
	"/usr/bin/yq" \
	"/usr/local/bin/yq"

# Clean up the logs
RUN find "/var/log" -type "f" |xargs truncate -s0

ENTRYPOINT "/bin/bash"
