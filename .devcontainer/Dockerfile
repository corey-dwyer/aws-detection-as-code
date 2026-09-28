FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

# The base image ships an apt source for Yarn whose signing key is missing.
# That makes `apt-get update` fail, which breaks every devcontainer feature install.
# This project doesn't use Yarn, so remove that source (never disable signature checks).
RUN grep -rl "dl.yarnpkg.com" /etc/apt/sources.list.d/ 2>/dev/null | xargs -r rm -f
