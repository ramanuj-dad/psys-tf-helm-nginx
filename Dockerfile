FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    curl \
    jq \
    openssh-client \
    ca-certificates \
    git \
    unzip \
    tar

ARG TERRAFORM_VERSION=1.9.0
ARG KUBECTL_VERSION=v1.33.2
ARG HELM_VERSION=v3.15.0

RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

RUN curl -fsSL https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xz && \
    mv linux-amd64/helm /usr/local/bin/ && \
    rm -rf linux-amd64

WORKDIR /workspace
COPY . .

CMD ["/bin/bash"]
