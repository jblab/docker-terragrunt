# ----------------------------------------------------------------------------------------------------------------------
# BASE
# ----------------------------------------------------------------------------------------------------------------------
FROM ubuntu:noble AS base

LABEL org.opencontainers.image.ref.name=jbonnier/terragrunt
LABEL org.opencontainers.image.source=https://github.com/jblab/docker-terragrunt
LABEL org.opencontainers.image.description="Docker image with Terraform and Terragrunt for consistent, versioned infrastructure deployment."
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.vendor=jblab

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG TERRAFORM_VERSION=1.15.5
ARG TERRAGRUNT_VERSION=1.0.7
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG HOME_DIR=/home/terragrunt

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eu; \
    userdel -r ubuntu || true; \
    groupdel ubuntu || true; \
    if [ "$GROUP_ID" -ne 0 ]; then \
        if ! getent group "$GROUP_ID" > /dev/null 2>&1; then \
            groupadd --gid "$GROUP_ID" terragrunt; \
        fi; \
    fi; \
    if [ "$USER_ID" -ne 0 ]; then \
        if ! getent passwd "$USER_ID" > /dev/null 2>&1; then \
            useradd \
                --uid "$USER_ID" \
                --gid "$GROUP_ID" \
                --home "$HOME_DIR" \
                --create-home \
                --shell /sbin/nologin \
                terragrunt; \
        fi; \
    fi;

RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends git openssh-client curl ca-certificates unzip; \
    rm -rf /var/lib/apt/lists/*;

RUN set -eu; \
    case "$TARGETPLATFORM" in \
      linux/amd64) ARCH_SUFFIX="linux_amd64";; \
      linux/arm64) ARCH_SUFFIX="linux_arm64";; \
      *) echo "Unsupported TARGETPLATFORM=${TARGETPLATFORM}" >&2; exit 1;; \
    esac; \
    curl -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${ARCH_SUFFIX}.zip; \
    curl -s https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS | grep "terraform_${TERRAFORM_VERSION}_${ARCH_SUFFIX}.zip" | awk '{print $1}' > terraform.sha256; \
    echo "$(cat terraform.sha256)  terraform.zip" | sha256sum -c -; \
    unzip terraform.zip; \
    rm terraform.zip terraform.sha256; \
    mv terraform /usr/local/bin/; \
    chmod +x /usr/local/bin/terraform; \
    terraform -version

RUN set -eu; \
    case "$TARGETPLATFORM" in \
      linux/amd64) ARCH_SUFFIX="linux_amd64";; \
      linux/arm64) ARCH_SUFFIX="linux_arm64";; \
      *) echo "Unsupported TARGETPLATFORM=${TARGETPLATFORM}" >&2; exit 1;; \
    esac; \
    curl -Lo terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_${ARCH_SUFFIX}; \
    curl -Ls https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS | grep " terragrunt_${ARCH_SUFFIX}$" | awk '{print $1}' > terragrunt.sha256; \
    echo "$(cat terragrunt.sha256)  terragrunt" | sha256sum -c -; \
    rm terragrunt.sha256; \
    mv terragrunt /usr/local/bin/; \
    chmod +x /usr/local/bin/terragrunt; \
    terragrunt -version

ENTRYPOINT []

# ----------------------------------------------------------------------------------------------------------------------
# DEV
# ----------------------------------------------------------------------------------------------------------------------
FROM base AS dev

RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends vim tree make graphviz jq; \
    rm -rf /var/lib/apt/lists/*;

RUN set -eu; \
    case "$TARGETPLATFORM" in \
      linux/amd64) ARCH_SUFFIX="x86_64";; \
      linux/arm64) ARCH_SUFFIX="aarch64";; \
      *) echo "Unsupported TARGETPLATFORM=${TARGETPLATFORM}" >&2; exit 1;; \
    esac; \
    cd tmp; \
    LATEST_VERSION=$(curl --silent "https://api.github.com/repos/casey/just/releases/latest" | jq -r ".tag_name"); \
    LATEST_VERSION_FILENAME="just-${LATEST_VERSION}-${ARCH_SUFFIX}-unknown-linux-musl.tar.gz"; \
    curl -Lo just.tar.gz https://github.com/casey/just/releases/download/${LATEST_VERSION}/${LATEST_VERSION_FILENAME}; \
    curl -Ls https://github.com/casey/just/releases/download/${LATEST_VERSION}/SHA256SUMS | grep " ${LATEST_VERSION_FILENAME}$" | awk '{print $1}' > just.sha256; \
    echo "$(cat just.sha256)  just.tar.gz" | sha256sum -c -; \
    mkdir just; \
    tar zxvf just.tar.gz -C just; \
    mv just/just /usr/local/bin; \
    chmod +x /usr/local/bin/just; \
    rm -rf just just.tar.gz just.sha256; \
    mkdir -p "/opt/just/"; \
    just --completions bash > "/opt/just/just.sh"; \
    just --version

USER terragrunt

STOPSIGNAL SIGKILL
CMD ["sleep", "infinity"]

# ----------------------------------------------------------------------------------------------------------------------
# ADO Builder target, this image should be pushed to a Docker registry and used by the Azure DevOps Build Agent.
# Build it with: docker build -t namespace/image_name:version --target ado_builder .
# ----------------------------------------------------------------------------------------------------------------------
FROM base AS ado_builder

ARG NODE_MAJOR="24"

RUN set -eu; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates gnupg; \
    mkdir -p /etc/apt/keyrings ; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs; \
    rm -rf /var/lib/apt/lists/*; \
    node --version;

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/bin/node"
