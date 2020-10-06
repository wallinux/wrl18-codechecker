# wrl18-codechecker build

Build wrlinux18 with the static code analyser CodeChecker.
The results are stored on a CodeChecker webserver running at localhost:8003

## Prerequisites:
* wrlinux 18 installed
* docker installed and working as non-root user


## Build steps:
0. To see available rules type
`make help`

1. create a hostconfig-$(hostname).mk file with the following content
```
# Define where you have wrlinux 18
WRL_INSTALL_DIR	= /opt/projects/ericsson/installs/wrlinux_lts18

# Define to trace cmd's
# V=1
```
2. start Codechecker web server (http://localhost:8003)
`make codechecker.server.start`

3. start docker image using modified crops/poky image
`make docker.start`

4. login to docker container
`make docker.shell`

5. setup and configure to build IMAGE=wrlinux-image-small with MACHINE=qemux86-64
`make configure`

6. build one package with codechecker e.g. package byusybox
`make pkg.ALL`

7. Check codechecker result in the webserver, http://localhost:8003


### Podman build
- Not tested/working

## References:
- https://github.com/Ericsson/codechecker
- https://github.com/Ericsson/codechecker/blob/master/docs/web/docker.md
- https://github.com/dl9pf/meta-codechecker
- https://codechecker.readthedocs.io/en/latest/analyzer/user_guide/#bitbake
