# ----------------------------------------------------------------------------------------------------------------------
# BASE
# ----------------------------------------------------------------------------------------------------------------------
FROM ubuntu:jammy AS base

ARG TERRAFORM_VERSION=1.12.2
ARG TERRAGRUNT_VERSION=0.85.0
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN set -eu; \
    groupadd --gid $GROUP_ID --system terragrunt; \
    useradd \
        --uid $USER_ID \
        --gid $GROUP_ID \
        --home /home/terragrunt \
        --system \
        --shell /sbin/nologin \
        terragrunt

RUN set -eu; \
    apt update; \
    apt install -y --no-install-recommends git openssh-client curl ca-certificates unzip; \
    rm -rf /var/lib/apt/lists/*;

RUN set -eu; \
    curl -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip; \
    unzip terraform.zip; \
    rm terraform.zip; \
    mv terraform /usr/local/bin/; \
    chmod +x /usr/local/bin/terraform; \
    terraform -version

ADD https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /usr/local/bin/terragrunt
RUN set -e; \
    chmod +x /usr/local/bin/terragrunt; \
    terragrunt -version

ENTRYPOINT []

# ----------------------------------------------------------------------------------------------------------------------
# DEV
# ----------------------------------------------------------------------------------------------------------------------
FROM base AS dev

RUN set -eu; \
    apt update; \
    apt install -y --no-install-recommends vim tree make graphviz; \
    rm -rf /var/lib/apt/lists/*;

USER terragrunt

STOPSIGNAL SIGKILL
CMD ["sleep", "infinity"]

# ----------------------------------------------------------------------------------------------------------------------
# ADO Builder target, this image should be pushed to a Docker registry and used by the Azure DevOps Build Agent.
# Build it with: docker build -t namespace/image_name:version --target terragrunt_ado_builder .
# ----------------------------------------------------------------------------------------------------------------------
FROM base AS ado_builder

ARG NODE_MAJOR="20"

RUN set -eu; \
    apt-get update; \
    apt-get install -y ca-certificates gnupg; \
    mkdir -p /etc/apt/keyrings ; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install nodejs -y; \
    rm -rf /var/lib/apt/lists/*;

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/bin/node"
