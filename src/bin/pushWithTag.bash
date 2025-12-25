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

# Ensure git status is clean
if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working directory is not clean - commit or stash changes first" >&2
  exit 1
fi

# Ensure tag exists locally
if ! git rev-parse "${TAG_VERSION}" >/dev/null 2>&1; then
  echo "ERROR: Tag ${TAG_VERSION} does not exist locally - run seedTag.bash first" >&2
  exit 1
fi

# Check tag doesn't exist on remote
if git ls-remote --tags origin "${TAG_VERSION}" 2>/dev/null | grep -q "${TAG_VERSION}"; then
  echo "ERROR: Tag ${TAG_VERSION} already exists on remote" >&2
  exit 1
fi

git push origin main "${TAG_VERSION}"

echo "Pushed main and tag ${TAG_VERSION} to origin"
