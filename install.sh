#!/usr/bin/env bash
# Install PDF Password Remover: CLI tools, qpdf dependency, and Finder services.

set -euo pipefail

readonly PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly INSTALL_PREFIX="${INSTALL_PREFIX:-${HOME}/.local}"
readonly BIN_DIR="${INSTALL_PREFIX}/bin"
readonly SERVICES_DIR="${HOME}/Library/Services"
readonly WORKFLOWS=(
  "UnlockPDF.workflow"
)

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
  install -m 755 "${PROJECT_DIR}/bin/pdf-unlock-service" "${BIN_DIR}/pdf-unlock-service"
  install -d "${BIN_DIR}/lib"
  install -m 644 "${PROJECT_DIR}/bin/lib/keychain.sh" "${BIN_DIR}/lib/keychain.sh"
  log "Installed CLI tools to ${BIN_DIR}"
  install_path
}

install_path() {
  case ":${PATH}:" in
    *":${BIN_DIR}:"*) ;;
    *)
      local profile="${HOME}/.zshrc"
      if [[ -f "$profile" ]] && ! grep -q '\.local/bin' "$profile" 2>/dev/null; then
        cat >>"$profile" <<EOF

# pdf-password-remover CLI tools
export PATH="\${HOME}/.local/bin:\$PATH"
EOF
        log "Added ${BIN_DIR} to PATH in ~/.zshrc"
      else
        log "Add to your shell profile (~/.zshrc):"
        echo "    export PATH=\"${BIN_DIR}:\$PATH\""
      fi
      ;;
  esac
}

register_service() {
  local dest="$1"
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$dest" 2>/dev/null || true
  xattr -cr "$dest" 2>/dev/null || true
}

install_quick_actions() {
  mkdir -p "$SERVICES_DIR"

  # Remove legacy workflows from earlier installs.
  rm -rf \
    "${SERVICES_DIR}/Unlock PDFs.workflow" \
    "${SERVICES_DIR}/Unlock PDF.workflow" \
    "${SERVICES_DIR}/Unlock PDFs in Folder.workflow"

  local name src dest
  for name in "${WORKFLOWS[@]}"; do
    src="${PROJECT_DIR}/quick-action/${name}"
    dest="${SERVICES_DIR}/${name}"
    [[ -d "$src" ]] || die "Workflow not found at ${src}"
    rm -rf "$dest"
    cp -R "$src" "$dest"
    register_service "$dest"
    log "Installed Finder service: ${dest}"
  done

  xattr -cr "${BIN_DIR}" 2>/dev/null || true
  /System/Library/CoreServices/pbs -flush 2>/dev/null || true
  killall Finder 2>/dev/null || true
}

main() {
  log "PDF Password Remover — install"
  ensure_homebrew
  install_qpdf
  install_cli
  install_quick_actions

  echo ""
  log "Installation complete."
  echo ""
  echo "Next steps:"
  echo "  1. Add your PDF password(s):  pdf-password add"
  echo "  2. Allow Finder access:       pdf-password trust"
  echo "  3. Test Keychain access:      pdf-password test"
  echo "  4. In Finder, right-click a PDF or folder → Services → Unlock PDF"
  echo ""
  echo "If it fails, check the log:"
  echo "  ~/Library/Logs/pdf-password-remover.log"
  echo ""
  echo "Passwords are stored in macOS Keychain only — never in this repo."
}

main "$@"
