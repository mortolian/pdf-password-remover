#!/usr/bin/env bash
# Create the GitHub repo, set metadata, and push. Requires GH_TOKEN or prior `gh auth login`.
set -euo pipefail

readonly REPO="mortolian/pdf-password-remover"
readonly DESCRIPTION="Batch remove PDF password protection on macOS — Keychain-secured passwords, CLI, and Finder Quick Action."
readonly HOMEPAGE="https://github.com/mortolian/pdf-password-remover"
readonly TOPICS=(
  macos
  pdf
  pdf-password
  pdf-unlock
  automation
  keychain
  qpdf
  shell-script
  finder
  quick-action
  batch-processing
  password-remover
  homebrew
)

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v gh >/dev/null 2>&1; then
  echo "error: install GitHub CLI: brew install gh" >&2
  exit 1
fi

if [[ -z "${GH_TOKEN:-}" ]] && ! gh auth status >/dev/null 2>&1; then
  echo "error: set GH_TOKEN or run: gh auth login" >&2
  exit 1
fi

if gh repo view "$REPO" >/dev/null 2>&1; then
  echo "Repository $REPO already exists."
else
  echo "Creating $REPO..."
  gh repo create "$REPO" \
    --public \
    --description "$DESCRIPTION" \
    --homepage "$HOMEPAGE" \
    --source . \
    --remote origin \
    --push
fi

echo "Setting repository metadata..."
topic_args=()
for t in "${TOPICS[@]}"; do
  topic_args+=(--add-topic "$t")
done

gh repo edit "$REPO" \
  --description "$DESCRIPTION" \
  --homepage "$HOMEPAGE" \
  --enable-issues=true \
  --enable-wiki=false \
  --enable-projects=false \
  "${topic_args[@]}"

if ! git rev-parse --verify origin/main >/dev/null 2>&1; then
  git push -u origin main
fi

echo ""
echo "Done: https://github.com/$REPO"
