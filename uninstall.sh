#!/usr/bin/env bash
# Remove installed CLI tools and Finder services.

set -euo pipefail

readonly INSTALL_PREFIX="${INSTALL_PREFIX:-${HOME}/.local}"
readonly BIN_DIR="${INSTALL_PREFIX}/bin"
readonly SERVICES_DIR="${HOME}/Library/Services"
readonly WORKFLOWS=(
  "UnlockPDF.workflow"
  "Unlock PDF.workflow"
  "Unlock PDFs.workflow"
  "Unlock PDFs in Folder.workflow"
)

log() { echo "==> $*"; }

rm -f "${BIN_DIR}/pdf-unlock" "${BIN_DIR}/pdf-password" "${BIN_DIR}/pdf-unlock-finder" "${BIN_DIR}/pdf-unlock-service"
rm -rf "${BIN_DIR}/lib"
log "Removed CLI tools from ${BIN_DIR} (if present)"

for name in "${WORKFLOWS[@]}"; do
  rm -rf "${SERVICES_DIR}/${name}"
done
log "Removed Finder services (if present)"

/System/Library/CoreServices/pbs -flush 2>/dev/null || true

echo ""
log "Uninstall complete."
echo "Keychain passwords were NOT removed. To delete them: pdf-password list && pdf-password remove <name>"
