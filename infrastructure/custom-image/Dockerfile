FROM debian:bullseye-slim

# Install dependencies and basic tools
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install yq (YAML processor written in Go)
ENV YQ_VERSION=v4.40.5
RUN curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Install kubectl
ENV KUBECTL_VERSION=v1.29.0
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Install Vault
ENV VAULT_VERSION=1.16.1
RUN curl -L "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" -o vault.zip && \
    unzip vault.zip && \
    mv vault /usr/local/bin/ && \
    rm vault.zip

# Set default shell and entrypoint
CMD ["/bin/bash"]
