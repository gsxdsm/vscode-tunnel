# Ubuntu 24.04 LTS base image
FROM ubuntu:24.04

# Install packages
RUN apt-get -q update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends build-essential buildah ca-certificates curl git gpg jq less make nodejs npm openjdk-17-jdk openssl python3 python3-pip python3-virtualenv unzip vim wget yq zip && \
    rm -rf /var/lib/apt/lists/*

# Import additional root CA
ARG ROOT_CA_URL=
RUN test -z "${ROOT_CA_URL}" || (curl -sSLf -O --output-dir /usr/local/share/ca-certificates "${ROOT_CA_URL}" && update-ca-certificates)


# Download and install VS Code CLI
ARG VSCODE_CLI_VERSION=1.95.3
RUN VSCODE_CLI_URL=$(curl -sSLf "https://update.code.visualstudio.com/api/versions/${VSCODE_CLI_VERSION}/cli-alpine-x64/stable" | jq -r ".url") && \
    curl -sSLf -o /tmp/vscode-cli.tar.gz "${VSCODE_CLI_URL}" && \
    tar -xf /tmp/vscode-cli.tar.gz -C /usr/local/bin && \
    rm -f /tmp/vscode-cli.tar.gz

# Copy files
COPY entrypoint.sh /entrypoint.sh

# Create user
ARG USER_UID=1000
ARG USER_GID=100
RUN userdel ubuntu && rm -Rf /home/ubuntu && useradd -o -s /bin/bash -u ${USER_UID} -g ${USER_GID} -m vscode
USER ${USER_UID}
WORKDIR /home/vscode

# Startup
ENTRYPOINT ["/entrypoint.sh"]
