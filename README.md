Customized "fat" Debian Docker image with bunch of tools for testing and development.

This image is built on top of the [Debian](https://www.debian.org/) and includes bunch of tools for testing, such as basic build toolchain. This is by no means a small container, and it quite likely contains unnecessary attack surface for application specific containers. As such is quite unlikely suitable for production application container base, but it can be useful for developing and debugging before the production phase. 

Personally I am using it a lot to separate applications from each other when testing things so that different instances don't mess up with each other while they store authentication, cache or similar data to the home directory. 

# Building
There is automated build that builds the image to the Docker hub, available as `mireiawen/debian`. 

You can build customized image for your user by running the `build.sh` in the repository root. This requires that you have [Jinja2 CLI](https://github.com/kolypto/j2cli) installed. This will create image named as `mireiawen/debian:<your username>` where you can run the commands as normal user instead of the root user.

# Running
Running the container is like starting up any interactive container, it starts with the bash shell:

```
docker run \
        --rm \
        --interactive \
        --tty \
        mireiawen/debian
```

Running as normal user requires that you build customized image in some way. There is helper script available to create that automatically, as described in the Build step. To run as normal user, just run the created container. There is helper script `start-container` to run the container created with helper script and specify some options.

## `start-container` -helper
Runs the container in interactive mode, and removes it after use. Tries to mount the Docker socket to the container for Docker in Docker -use. 
**Note:** GNU getopt is required to run the helper script.

| Short option     | Long option             |  Description                        |
|------------------|-------------------------|-------------------------------------|
| `-m`             | `--mount-home`          | Mount the current user home directory to the container and run the user container |
| `-r`             | `--mount-home-readonly` | Mount the current user home directory to the container as read-only and run the user container |
| `-u`             | `--user-tag`            | Run the user container              |
| `-t <tag>`       | `--tag <tag>`           | Run the container with specific tag |
| `-e <key=value>` | `--env <key=value>`     | Add environment variables, like in Docker command. Can be specified multiple times |
| `-v <volume>`    | `--volume <volume>`     | Add volume, like in Docker `--volume` parameter. Script tries to parse the mount point and chown it recursively to the user when running with mount-home or mount-home-readonly. Can be specified multiple times |

# Available external tools
* [Package installer script](https://github.com/bitnami/minideb) `install_packages` from `bitnami/minideb:buster`
* [gosu](https://github.com/tianon/gosu) `gosu` command
* [Docker client](https://www.docker.com/) `docker` as Docker in Docker (DinD) from `docker:dind`
* [Kubernetes CLI client](https://www.docker.com/) `kubectl` from `bitnami/kubectl:latest`
* [OpenShift Origin CLI client](https://www.okd.io/) `oc`  from `openshift/origin:latest`
* [Hashicorp Vault client](https://www.vaultproject.io/) `vault` from `vault:latest`
* [Python 3](https://www.python.org/) package installer `pip3` from Debian repository
* [Jinja2 CLI](https://github.com/kolypto/j2cli) `j2` from Python Package Index
* [JQ](https://stedolan.github.io/jq/) (JSON) command `jq` from Debian repository
* [YQ](https://github.com/mikefarah/yq) (YAML) command `yq` from `mikefarah/yq`
* [Ansible CLI](https://www.ansible.com/) `ansible` from Python Package Index
* [Ansible linter](https://github.com/ansible/ansible-lint) `ansible-lint` from Python Package Index
* [Ansible role tester](https://github.com/ansible-community/molecule) `molecule` from Python Package Index
* [Container security scanner](https://github.com/aquasecurity/trivy) `trivy` from `aquasec/trivy:latest`
* [Shell checker](https://github.com/koalaman/shellcheck) `shellcheck` from `koalaman/shellcheck:stable`
