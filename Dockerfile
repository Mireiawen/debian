FROM "debian:9"
MAINTAINER "Mira Liikanen <mir@mireiawen.net>"

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND "noninteractive"

# Install some basic tools for use
RUN \
	apt-get "update" && \
	apt-get "install" -y \
		"aptitude" \
		"dnsutils" \
		"less" \
		"locales" \
		"lsb-release" \
		"jq" \
		"vim" \
		"wget"

# Enable the backports repository
COPY "backports.sh" "/backports.sh"
RUN \
	sh "/backports.sh" && \
	rm "/backports.sh"

# Make sure we generate the locales
RUN \
	echo "en_US.UTF-8 UTF-8" >"/etc/locale.gen" && \
	/usr/sbin/locale-gen && \
	/usr/sbin/update-locale LANG="en_US.UTF-8"

# Clean up the logs
RUN find "/var/log" -type "f" |xargs truncate -s0
