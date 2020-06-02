Customized "fat" Debian Docker image with bunch of tools for testing

This image is built on top of the [Debian](https://www.debian.org/) and includes bunch of tools for testing, such as basic build toolchain. This is by no means a small container, and it quite likely contains unnecessary attack surface for the real applications and as such is quite unlikely suitable for real application use, but instead developing and debugging step.

# Running
Running the container is like starting up any interactive container, it starts with the bash shell:

```
docker run \
	--rm \
	--interactive \
	--tty \
	mireiawen/debian
```

# Other
This container uses the `install_packages` -script from the [Bitnami Minideb](https://github.com/bitnami/minideb)
