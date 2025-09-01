#!/usr/bin/env bash
set -euo pipefail

FAIL_ON_WARNINGS="${FAIL_ON_WARNINGS:-false}"
REPO=/workspace
ART_DIR="$REPO/.ci-artifacts"
mkdir -p "$ART_DIR"

mkdir -p "$XDG_CONFIG_HOME"
if [ -L "$XDG_CONFIG_HOME/nvim" ] || [ -d "$XDG_CONFIG_HOME/nvim" ]; then
  rm -rf "$XDG_CONFIG_HOME/nvim"
fi
ln -s "$REPO" "$XDG_CONFIG_HOME/nvim"

{
  echo "NEOVIM: $(nvim --version | head -n1)"
  echo "PYTHON: $(python3 --version 2>&1)"
  echo "NODE:   $(node --version 2>&1 || true)"
  echo "NPM:    $(npm --version 2>&1 || true)"
  echo "RIPGREP: $(rg --version 2>&1 | head -n1 || true)"
} | tee "$ART_DIR/versions.txt"

# Detect plugin manager
PM="none"
if grep -Rqi 'lazy\.nvim' "$REPO"; then PM="lazy"; fi
if grep -Rqi 'packer\.startup' "$REPO"; then PM="packer"; fi

echo "$PM" > "$ART_DIR/plugin-manager.txt"
echo "Detected plugin manager: $PM"

# headless boot to install/sync plugins
if [ "$PM" = "lazy" ]; then
  echo "Running Lazy! sync..."
  nvim --headless "+Lazy! sync" "+qa" || { echo "Lazy sync failed"; exit 1; }
elif [ "$PM" = "packer" ]; then
  echo "Running PackerSync..."
  nvim --headless \
    -c "autocmd User PackerComplete quitall" \
    -c "PackerSync" || { echo "Packer sync failed"; exit 1; }
else
  echo "No known plugin manager detected. Doing a no-op boot..."
  nvim --headless "+qa"
fi

# boot to ensure post-install hooks/compilation settled
nvim --headless "+qa"

# file for health report
HEALTH="$ART_DIR/health.txt"

nvim --headless +'set nomore' +"silent! checkhealth" +"w! $HEALTH" +qa || true
#  - run :checkhealth silently
#  - write current buffer to file
#  - quit all

# parse results: Neovim Health uses OK / WARNING / ERROR markers
errors=$(grep -E '(^\s*ERROR|✗|×)' -c "$HEALTH" || true)
warnings=$(grep -E '(^\s*WARNING|⚠)' -c "$HEALTH" || true)
oks=$(grep -E '(^\s*OK|✓)' -c "$HEALTH" || true)

echo "Health summary: OK=$oks WARNING=$warnings ERROR=$errors"

if [ "${errors:-0}" -gt 0 ]; then
  echo "Failing: health report contains errors."
  exit 1
fi
if [ "${FAIL_ON_WARNINGS}" = "true" ] && [ "${warnings:-0}" -gt 0 ]; then
  echo "Failing due to warnings per FAIL_ON_WARNINGS=true."
  exit 2
fi

echo "Nvim health looks good."
