FROM debian:trixie-20251208-slim
# Always use the most specific tag possible

# Required plain semantic version tag - X.Y.Z eg 1.23.4
ARG VERSION

# Grab the image name so that if the image is ever separated from its name people can tell what it is
ARG TARGET_IMAGE_NAME

# Set the tool versions for use below
ENV KUBECTL_VERSION=1.31.14
ENV YQ_VERSION=4.50.1

# Validate VERSION is provided
RUN if [ -z "${VERSION}" ]; then \
        echo "ERROR: VERSION must be provided" && exit 42; \
    fi

# Validate VERSION matches KUBECTL_VERSION major.minor
RUN VERSION_MAJOR_MINOR=$(echo "${VERSION}" | cut -d. -f1-2) && \
    KUBECTL_MAJOR_MINOR=$(echo "${KUBECTL_VERSION}" | cut -d. -f1-2) && \
    if [ "${VERSION_MAJOR_MINOR}" != "${KUBECTL_MAJOR_MINOR}" ]; then \
        echo "ERROR: VERSION (${VERSION}) and KUBECTL_VERSION (${KUBECTL_VERSION}) major.minor must match" && exit 42; \
    fi

# Set labels for metadata
LABEL description="Keelson - Keelson Base Image"
LABEL version="${VERSION}"
LABEL image.name="${TARGET_IMAGE_NAME}"
LABEL kubectl.version="${KUBECTL_VERSION}"
LABEL yq.version="${YQ_VERSION}"

# Install required packages and clean up
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    netcat-openbsd
RUN rm -rf /var/lib/apt/lists/*

# Install yq 4
RUN curl -fsSL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq

# Install kubectl
RUN curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

# Create non-root user for security
RUN groupadd -r keelson
RUN useradd -r -g keelson -s /bin/bash keelson
