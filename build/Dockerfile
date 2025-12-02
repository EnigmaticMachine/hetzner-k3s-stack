FROM python:3.12-slim-bookworm

# Install Tools
RUN apt-get update && apt-get install -y \
    curl unzip git openssh-client make jq \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
ENV TERRAFORM_VERSION=1.9.5
RUN curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Ansible & Hcloud
RUN pip install ansible==10.3.0 hcloud pyyaml

# Install Hetzner CLI
ENV HCLOUD_VERSION=v1.45.0
RUN curl -L "https://github.com/hetznercloud/cli/releases/download/${HCLOUD_VERSION}/hcloud-linux-amd64.tar.gz" | tar xz \
    && mv hcloud /usr/local/bin/hcloud

WORKDIR /project
