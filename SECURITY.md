# Security Policy

## Password storage

**Passwords are stored only in the macOS Keychain**, not in this repository, config files, or environment variables.

- Service name: `pdf-password-remover`
- Each password has a label (account name) you choose, e.g. `default`, `work`
- Keychain data is encrypted by macOS and can sync via iCloud Keychain if you enable it

**Do not:**

- Commit `.env` files with passwords
- Pass passwords on the command line (they would appear in shell history)
- Store passwords in plaintext files

## Reporting vulnerabilities

If you find a security issue, please open a [GitHub Security Advisory](https://github.com/mortolian/pdf-password-remover/security/advisories/new) or email the maintainer privately. Do not file public issues for undisclosed vulnerabilities.

## Threat model

This tool is intended for **your own PDFs** where you know the password. It decrypts files locally using [qpdf](https://github.com/qpdf/qpdf). It does not upload files or passwords anywhere.
