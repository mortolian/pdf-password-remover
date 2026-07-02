#!/usr/bin/env bash
# Install PDF Password Remover: CLI tools, qpdf dependency, and Finder Quick Action.

set -euo pipefail

readonly PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly INSTALL_PREFIX="${INSTALL_PREFIX:-${HOME}/.local}"
readonly BIN_DIR="${INSTALL_PREFIX}/bin"
readonly SERVICES_DIR="${HOME}/Library/Services"
readonly WORKFLOW_NAME="Unlock PDFs.workflow"

log() { echo "==> $*"; }
die() { echo "error: $*" >&2; exit 1; }

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  die "Homebrew is required. Install from https://brew.sh then re-run ./install.sh"
}

install_qpdf() {
  if command -v qpdf >/dev/null 2>&1; then
    log "qpdf already installed: $(qpdf --version | head -1)"
    return 0
  fi
  log "Installing qpdf via Homebrew..."
  brew install qpdf
}

install_cli() {
  mkdir -p "$BIN_DIR"
  install -m 755 "${PROJECT_DIR}/bin/pdf-unlock" "${BIN_DIR}/pdf-unlock"
  install -m 755 "${PROJECT_DIR}/bin/pdf-password" "${BIN_DIR}/pdf-password"
  install -m 755 "${PROJECT_DIR}/bin/pdf-unlock-finder" "${BIN_DIR}/pdf-unlock-finder"
  log "Installed CLI tools to ${BIN_DIR}"

  case ":${PATH}:" in
    *":${BIN_DIR}:"*) ;;
    *)
      log "Add to your shell profile (~/.zshrc):"
      echo "    export PATH=\"${BIN_DIR}:\$PATH\""
      ;;
  esac
}

install_quick_action() {
  local src="${PROJECT_DIR}/quick-action/${WORKFLOW_NAME}"
  local dest="${SERVICES_DIR}/${WORKFLOW_NAME}"

  [[ -d "$src" ]] || die "Quick Action workflow not found at ${src}"

  mkdir -p "$SERVICES_DIR"
  rm -rf "$dest"
  cp -R "$src" "$dest"
  log "Installed Finder Quick Action: ${dest}"
  log "Enable it in System Settings → Privacy & Security → Extensions → Finder"
}

main() {
  log "PDF Password Remover — install"
  ensure_homebrew
  install_qpdf
  install_cli
  install_quick_action

  echo ""
  log "Installation complete."
  echo ""
  echo "Next steps:"
  echo "  1. Add your PDF password(s):  pdf-password add"
  echo "  2. Test Keychain access:      pdf-password test"
  echo "  3. Unlock a folder:           pdf-unlock ~/path/to/folder"
  echo "  4. In Finder: right-click a folder → Quick Actions → Unlock PDFs"
  echo ""
  echo "Passwords are stored in macOS Keychain only — never in this repo."
}

main "$@"
