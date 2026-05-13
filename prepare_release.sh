#!/usr/bin/env bash

set -euo pipefail

CONDA_ENV_NAME="${CONDA_ENV_NAME:-2024_14}"

usage() {
  cat >&2 <<'EOF'
Usage:
  ./prepare_release.sh <version>

Examples:
  ./prepare_release.sh 0.12.3
EOF
}

fail() {
  echo "Error: $1" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

INPUT_VERSION="$1"
TAG_PREFIX="valhalla-code-v"

PACKAGE_VERSION="${INPUT_VERSION}"
PACKAGE_VERSION="${PACKAGE_VERSION#v}"
TAG_VERSION="${TAG_PREFIX}${PACKAGE_VERSION}"

SEMVER_CORE_REGEX='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'


if [[ ! "${PACKAGE_VERSION}" =~ ${SEMVER_CORE_REGEX} ]]; then
  fail "${PACKAGE_VERSION} version must look like 1.2.3: three integers separated by periods, with no leading zeros."
fi

CURRENT_BRANCH="$(git branch --show-current)"
if [[ "${CURRENT_BRANCH}" != "main" ]]; then
  fail "Releases must be created from the main branch. Current branch: ${CURRENT_BRANCH}"
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  fail "Working tree has tracked changes. Commit or stash them before preparing a release."
fi

if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
  fail "Working tree has untracked files. Clean them up before preparing a release."
fi

if git rev-parse -q --verify "refs/tags/${TAG_VERSION}" >/dev/null; then
  fail "Tag ${TAG_VERSION} already exists locally."
fi

if git ls-remote --exit-code --tags origin "refs/tags/${TAG_VERSION}" >/dev/null 2>&1; then
  fail "Tag ${TAG_VERSION} already exists on origin."
fi

if ! command -v python >/dev/null 2>&1; then
  fail "python is not on PATH. Activate the release environment first."
fi

if [[ -n "${CONDA_DEFAULT_ENV:-}" && "${CONDA_DEFAULT_ENV}" != "${CONDA_ENV_NAME}" ]]; then
  fail "Current conda env is ${CONDA_DEFAULT_ENV}; expected ${CONDA_ENV_NAME}."
fi

echo "Preparing release ${TAG_VERSION}..."

git tag -a "${TAG_VERSION}" -m "Release ${TAG_VERSION}"
git push origin "${CURRENT_BRANCH}"
git push origin "${TAG_VERSION}"

echo "Release process for ${TAG_VERSION} completed successfully."
