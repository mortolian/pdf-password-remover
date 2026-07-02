#!/usr/bin/env bash
# Remove installed CLI tools and Finder Quick Action.

set -euo pipefail

readonly INSTALL_PREFIX="${INSTALL_PREFIX:-${HOME}/.local}"
readonly BIN_DIR="${INSTALL_PREFIX}/bin"
readonly SERVICES_DIR="${HOME}/Library/Services"
readonly WORKFLOW_NAME="Unlock PDFs.workflow"

log() { echo "==> $*"; }

rm -f "${BIN_DIR}/pdf-unlock" "${BIN_DIR}/pdf-password" "${BIN_DIR}/pdf-unlock-finder"
log "Removed CLI tools from ${BIN_DIR} (if present)"

rm -rf "${SERVICES_DIR}/${WORKFLOW_NAME}"
log "Removed Quick Action (if present)"

echo ""
log "Uninstall complete."
echo "Keychain passwords were NOT removed. To delete them: pdf-password list && pdf-password remove <name>"
