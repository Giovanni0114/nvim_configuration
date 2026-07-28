#!/usr/bin/env bash
# Local Neovim health check using your repo's .ci/Dockerfile and .ci/run_health.sh
# Fails fast if the CI files are missing or dirty (unless ALLOW_DIRTY=true).
#
# Usage examples:
#   ./ci_nvim_health.sh
#   NEOVIM_VERSION=nightly ./ci_nvim_health.sh
#   NEOVIM_VERSION=v0.10.4 UBUNTU=24.04 ./ci_nvim_health.sh
#   FAIL_ON_WARNINGS=true ./ci_nvim_health.sh
#   NVIM_CONFIG=/path/to/nvim ./ci_nvim_health.sh
#
set -euo pipefail

# ---- configurable via env ----
NEOVIM_VERSION="${NEOVIM_VERSION:-stable}"     # stable|nightly|vX.Y.Z
UBUNTU="${UBUNTU:-22.04}"                      # base image tag
FAIL_ON_WARNINGS="${FAIL_ON_WARNINGS:-false}"  # true/false
NVIM_CONFIG="${NVIM_CONFIG:-$PWD}"             # path to your nvim config repo
ALLOW_DIRTY="${ALLOW_DIRTY:-false}"            # set true to bypass git-clean check

# ---- paths ----
CI_DIR="$PWD/.ci"
DOCKERFILE="$CI_DIR/Dockerfile"
RUN_HEALTH="$CI_DIR/run_health.sh"
ART_DIR="$PWD/.ci-artifacts"

# ---- choose runtime ----
RUNTIME=""
if command -v docker >/dev/null 2>&1; then
  RUNTIME="docker"
elif command -v podman >/dev/null 2>&1; then
  RUNTIME="podman"
else
  echo "ERROR: neither docker nor podman is installed." >&2
  exit 1
fi

# ---- existence checks ----
[ -f "$DOCKERFILE" ] || { echo "ERROR: missing .ci/Dockerfile"; exit 1; }
[ -f "$RUN_HEALTH" ] || { echo "ERROR: missing .ci/run_health.sh"; exit 1; }
[ -d "$NVIM_CONFIG" ] || { echo "ERROR: NVIM_CONFIG not found: $NVIM_CONFIG"; exit 1; }

mkdir -p "$ART_DIR"

# ---- integrity / provenance info ----
echo "[*] Using Dockerfile: $DOCKERFILE"
echo "[*] Using runner:     $RUN_HEALTH"

IN_GIT="false"
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  IN_GIT="true"
fi

if [ "$IN_GIT" = "true" ]; then
  # ensure both files are tracked
  for f in "$DOCKERFILE" "$RUN_HEALTH"; do
    if ! git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      echo "ERROR: $f is not tracked by git. Commit it first." >&2
      exit 1
    fi
  done
  # ensure they’re clean unless overridden
  if [ "$ALLOW_DIRTY" != "true" ]; then
    if ! git diff --quiet -- "$DOCKERFILE" "$RUN_HEALTH"; then
      echo "ERROR: .ci files have uncommitted changes. Commit or set ALLOW_DIRTY=true." >&2
      git --no-pager diff --stat -- "$DOCKERFILE" "$RUN_HEALTH" || true
      exit 1
    fi
  fi
  # compute a deterministic tag tied to these files’ content
  FILE_HASH=$(git hash-object "$DOCKERFILE" "$RUN_HEALTH" | git hash-object --stdin)
  SHORT_HASH=$(printf "%s" "$FILE_HASH" | cut -c1-12)
else
  echo "[!] Not in a git repo; printing SHA256 of the files for your logs:"
  sha256sum "$DOCKERFILE" "$RUN_HEALTH" || true
  SHORT_HASH="$(sha256sum "$DOCKERFILE" "$RUN_HEALTH" | sha256sum | cut -c1-12 || echo nogit)"
fi

IMAGE_TAG="nvim-health:local-${UBUNTU}-${NEOVIM_VERSION}-${SHORT_HASH}"
echo "[*] Image tag: $IMAGE_TAG"

# ---- show a brief provenance summary ----
{
  echo "Provenance:"
  echo "  NEOVIM_VERSION = $NEOVIM_VERSION"
  echo "  UBUNTU         = $UBUNTU"
  echo "  FAIL_ON_WARNINGS = $FAIL_ON_WARNINGS"
  echo "  NVIM_CONFIG    = $NVIM_CONFIG"
  echo "  Runner SHA256  = $(sha256sum "$RUN_HEALTH" | awk '{print $1}')"
  echo "  Dockerfile SHA256 = $(sha256sum "$DOCKERFILE" | awk '{print $1}')"
} | tee "$ART_DIR/provenance.txt"

# ---- build image from your Dockerfile (no generated files) ----
echo "[*] Building image from .ci/Dockerfile (this may take a few minutes the first time)…"
$RUNTIME build \
  --build-arg "UBUNTU=${UBUNTU}" \
  --build-arg "NEOVIM_VERSION=${NEOVIM_VERSION}" \
  -t "$IMAGE_TAG" \
  -f "$DOCKERFILE" "$PWD"

echo "[*] Image built: $IMAGE_TAG"

# ---- run container, bind-mount the repo and .ci ----
# Note: we rely on your .ci/run_health.sh inside the repo for the logic.
echo "[*] Running health flow in container…"
set +e
$RUNTIME run --rm \
  -e "FAIL_ON_WARNINGS=${FAIL_ON_WARNINGS}" \
  -e "REPO=/workspace" \
  -v "$NVIM_CONFIG":/workspace \
  -v "$CI_DIR":/ci:ro \
  "$IMAGE_TAG" \
  /bin/bash -lc "/ci/run_health.sh"
rc=$?
set -e

echo "[*] Container exited with code: $rc"
if [ -f "$ART_DIR/health.txt" ]; then
  echo "[*] Health report: $ART_DIR/health.txt"
  echo "[*] Versions:      $ART_DIR/versions.txt"
  echo "[*] Plugin mgr:    $ART_DIR/plugin-manager.txt"
else
  echo "[!] No health report found in $ART_DIR (did the runner write artifacts?)."
fi

exit "$rc"

