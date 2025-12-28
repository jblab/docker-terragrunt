# ----------------------------------------------------------------------------------------------------------------------
# BASE
# ----------------------------------------------------------------------------------------------------------------------
FROM ubuntu:noble AS base

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG TERRAFORM_VERSION=1.14.3
ARG TERRAGRUNT_VERSION=0.96.1
ARG USER_ID=1000
ARG GROUP_ID=1000

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eu; \
    userdel ubuntu || true; \
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
                --home /home/terragrunt \
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
    unzip terraform.zip; \
    rm terraform.zip; \
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
    apt-get install -y --no-install-recommends vim tree make graphviz; \
    rm -rf /var/lib/apt/lists/*;

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
