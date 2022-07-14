# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: MIT

FROM ubuntu:20.04
WORKDIR /automation

# Install carvel tools, kubectl, shasum, and wget
RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates curl git jq libdigest-sha-perl wget && \
    curl https://carvel.dev/install.sh | bash && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    mv kubectl /usr/local/bin && \
    chmod a+x /usr/local/bin/kubectl &&  \
    rm -rf /var/lib/apt/lists/*

COPY . /automation/

VOLUME /data
