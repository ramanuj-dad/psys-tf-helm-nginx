# Multi-stage Dockerfile for Terraform/Helm/kubectl deployment container
FROM alpine:3.19 AS downloader

# Install download tools
RUN apk add --no-cache curl wget unzip

# Download Terraform
ARG TERRAFORM_VERSION=1.6.6
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    chmod +x terraform

# Download Helm
RUN curl https://get.helm.sh/helm-v3.13.3-linux-amd64.tar.gz | tar -xz && \
    mv linux-amd64/helm . && \
    chmod +x helm

# Download kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl

# Final runtime image
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    ca-certificates \
    openssh-client \
    && rm -rf /var/cache/apk/*

# Copy binaries from downloader stage
COPY --from=downloader /terraform /usr/local/bin/terraform
COPY --from=downloader /helm /usr/local/bin/helm
COPY --from=downloader /kubectl /usr/local/bin/kubectl

# Copy project files
COPY terraform/ /workspace/terraform/
COPY helm/ /workspace/helm/
COPY k8s/ /workspace/k8s/

# Create working directory and set permissions
WORKDIR /workspace

# Create non-root user for security
RUN addgroup -g 1000 runner && \
    adduser -D -u 1000 -G runner runner && \
    chown -R runner:runner /workspace

# Switch to non-root user
USER runner

# Verify installations
RUN terraform version && \
    helm version --client && \
    kubectl version --client

# Remove entry point script - we'll use direct commands
# COPY docker/entrypoint.sh /entrypoint.sh
# USER root
# RUN chmod +x /entrypoint.sh
# USER runner

# ENTRYPOINT ["/entrypoint.sh"]
