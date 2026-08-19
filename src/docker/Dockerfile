FROM debian:trixie-20260505-slim
# Always use the most specific tag possible

# Required plain semantic version tag - X.Y.Z eg 1.23.4
ARG VERSION

# Grab the image name so that if the image is ever separated from its name people can tell what it is
ARG TARGET_IMAGE_NAME

# Architecture from build system (used for binary downloads)
ARG DOCKER_PLATFORM_CPU_ARCHITECTURE

# Set the tool versions for use below
ENV KUBECTL_VERSION=1.36.1
ENV YQ_VERSION=4.53.2

# Strong checksums to match the above (per architecture)
ENV KUBECTL_SHA512_amd64=7ea15201c2981e79fe19540b574772679ee3b34424bf5d00c03ddeb1a7bacd0fda27db22637eafe9996b844ece73f09066c1f6bb275cd60f8560edac6e281147
ENV KUBECTL_SHA512_arm64=6a3d4bb486bbfc9185e520b6566d0fd09ee452febbce4ce92a870c5b42e40fcdd6dfd63caf38cf12efcf6282f83e45500e3bd0b6fafb0901d1bbf179533351c8
ENV YQ_SHA512_amd64=95d5755266c77627e6facc9b443174f17b94ab3b2c427b860232c7b79f56f1f534ed2e0b5a79b41dfcc8246a05db987d9aeb39913f36563784258ebe1d6be763
ENV YQ_SHA512_arm64=a4ffc2dc4f8c1c43e1ee687205248d361a16d0a0c6a7ceab17c443746b9d5d014dbccff5c34883bca9115979037ee2d992aa0e6d9a485a7184136df275f6729f

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
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    netcat-openbsd \
    skopeo \
    amazon-ecr-credential-helper
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Install yq 4
RUN curl -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${DOCKER_PLATFORM_CPU_ARCHITECTURE}" -o /usr/local/bin/yq
RUN sha512sum /usr/local/bin/yq
RUN eval CHECKSUM=\$YQ_SHA512_${DOCKER_PLATFORM_CPU_ARCHITECTURE} && \
    echo "${CHECKSUM}  /usr/local/bin/yq" | sha512sum -c -
RUN chmod +x /usr/local/bin/yq

# Install kubectl
RUN curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${DOCKER_PLATFORM_CPU_ARCHITECTURE}/kubectl" -o /usr/local/bin/kubectl
RUN sha512sum /usr/local/bin/kubectl
RUN eval CHECKSUM=\$KUBECTL_SHA512_${DOCKER_PLATFORM_CPU_ARCHITECTURE} && \
    echo "${CHECKSUM}  /usr/local/bin/kubectl" | sha512sum -c -
RUN chmod +x /usr/local/bin/kubectl

# Create runtime user with ID in var for setting later as kube requires ID not name
ENV KEELSON_USER_ID=4242
RUN mkdir -p /home/keelson # Required for kubectl to work correctly
RUN groupadd -g ${KEELSON_USER_ID} keelson
RUN useradd -u ${KEELSON_USER_ID} -g keelson -d /home/keelson -s /bin/bash keelson
RUN chown keelson:keelson /home/keelson

# Create directory structure for operational needs
RUN mkdir -p /keelson/bin        # Deployment scripts
RUN mkdir -p /keelson/secrets    # Pulled secrets cache dir
RUN mkdir -p /keelson/work       # Working dir for processing, logging, etc

# Put the keelson scripts on the path so we can run them naturally
ENV PATH="/keelson/bin:${PATH}"

# Deterministic time and text handling for every process in the image
ENV TZ=UTC
ENV LC_ALL=C

# Make the working dirs writeable and set the main one as the workdir
RUN chown keelson:keelson /keelson/secrets
RUN chown keelson:keelson /keelson/work
WORKDIR /keelson/work

ENV PS1="\u@\$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace 2>/dev/null || echo NOT_SET)/\h:\w\\$ "
