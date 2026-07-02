#!/usr/bin/env bash
# Shared Keychain helpers for pdf-password-remover.

KEYCHAIN_SERVICE="pdf-password-remover"
ACCOUNTS_FILE="${HOME}/.config/pdf-password-remover/accounts"

keychain_login_db() {
  local keychain="${HOME}/Library/Keychains/login.keychain-db"
  if [[ ! -f "$keychain" ]]; then
    keychain="${HOME}/Library/Keychains/login.keychain"
  fi
  if [[ -f "$keychain" ]]; then
    printf '%s' "$keychain"
  fi
}

accounts_file_init() {
  mkdir -p "$(dirname "$ACCOUNTS_FILE")"
  if [[ -f "$ACCOUNTS_FILE" ]]; then
    return 0
  fi
  if security find-generic-password -a "default" -s "$KEYCHAIN_SERVICE" >/dev/null 2>&1; then
    printf '%s\n' "default" > "$ACCOUNTS_FILE"
  fi
}

accounts_register() {
  local name="$1"
  accounts_file_init
  if [[ ! -f "$ACCOUNTS_FILE" ]] || ! grep -Fxq "$name" "$ACCOUNTS_FILE" 2>/dev/null; then
    printf '%s\n' "$name" >> "$ACCOUNTS_FILE"
    sort -u "$ACCOUNTS_FILE" -o "$ACCOUNTS_FILE"
  fi
}

accounts_unregister() {
  local name="$1"
  [[ -f "$ACCOUNTS_FILE" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  grep -Fxv "$name" "$ACCOUNTS_FILE" > "$tmp" || true
  mv "$tmp" "$ACCOUNTS_FILE"
}

keychain_accounts() {
  accounts_file_init
  if [[ -f "$ACCOUNTS_FILE" ]]; then
    cat "$ACCOUNTS_FILE"
    return 0
  fi
  return 0
}

keychain_trusted_apps() {
  local apps=(
    "/usr/bin/security"
    "/bin/zsh"
    "/bin/bash"
    "/usr/bin/osascript"
    "/System/Applications/Automator.app"
    "/System/Applications/Automator.app/Contents/MacOS/Automator"
    "/System/Library/CoreServices/Finder.app"
    "/System/Library/CoreServices/Finder.app/Contents/MacOS/Finder"
  )

  local name path
  for name in pdf-unlock pdf-unlock-finder pdf-password; do
    path="$(command -v "$name" 2>/dev/null || true)"
    [[ -n "$path" ]] && apps+=("$path")
    path="${HOME}/.local/bin/${name}"
    [[ -x "$path" ]] && apps+=("$path")
  done

  printf '%s\n' "${apps[@]}" | awk '!seen[$0]++'
}

keychain_update_trust() {
  local name="$1"
  local password="$2"
  local -a args=(
    add-generic-password
    -a "$name"
    -s "$KEYCHAIN_SERVICE"
    -w "$password"
    -U
  )

  local app
  while IFS= read -r app; do
    [[ -n "$app" ]] && args+=(-T "$app")
  done < <(keychain_trusted_apps)

  security "${args[@]}"
  accounts_register "$name"
}

keychain_refresh_trust() {
  local accounts account password updated=0
  accounts="$(keychain_accounts || true)"
  [[ -n "$accounts" ]] || return 1

  while IFS= read -r account; do
    [[ -z "$account" ]] && continue
    password="$(security find-generic-password -a "$account" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || true)"
    [[ -n "$password" ]] || continue
    keychain_update_trust "$account" "$password"
    updated=$((updated + 1))
  done <<< "$accounts"

  [[ "$updated" -gt 0 ]]
}
