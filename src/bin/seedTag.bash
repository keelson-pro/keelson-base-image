#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="${SCRIPT_DIR}/../docker/Dockerfile"

# Extract kubectl major.minor from Dockerfile
KUBECTL_VERSION=$(grep -E '^ENV KUBECTL_VERSION=' "${DOCKERFILE}" | cut -d= -f2)
if [[ -z "${KUBECTL_VERSION}" ]]; then
  echo "ERROR: Could not extract KUBECTL_VERSION from Dockerfile" >&2
  exit 1
fi

MAJOR_MINOR=$(echo "${KUBECTL_VERSION}" | cut -d. -f1-2)
TAG_VERSION="${MAJOR_MINOR}.0"

# Ensure Dockerfile is committed
if ! git diff --quiet -- "${DOCKERFILE}"; then
  echo "ERROR: Dockerfile has uncommitted changes - commit them first" >&2
  exit 1
fi

if ! git diff --cached --quiet -- "${DOCKERFILE}"; then
  echo "ERROR: Dockerfile has staged but uncommitted changes - commit them first" >&2
  exit 1
fi

# Ensure tag doesn't already exist
if git rev-parse "${TAG_VERSION}" >/dev/null 2>&1; then
  echo "ERROR: Tag ${TAG_VERSION} already exists" >&2
  exit 1
fi

# Create the tag
git tag -m "Seed tag for kube ${MAJOR_MINOR} +/-1 - version must match kubectl version inside Dockerfile build." "${TAG_VERSION}" HEAD

echo "Created tag ${TAG_VERSION}"
