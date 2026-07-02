# PDF Password Remover

Batch-remove password protection from PDF files on macOS. Includes a **Finder Quick Action** (right-click menu) and a command-line tool for automation.

Passwords are stored in the **macOS Keychain** — encrypted by the system, never written to disk or committed to git.

## Features

- Unlock all PDFs in a folder in one run
- **Recursive** or **current-folder-only** mode
- Try **multiple passwords** from Keychain (useful when files use different passwords)
- Finder **Quick Action**: right-click a folder → Unlock PDFs
- Safe defaults: writes `*-unlocked.pdf` copies; optional in-place replace with backup

## Requirements

- macOS 12 or later
- [Homebrew](https://brew.sh) (install script uses it for [qpdf](https://github.com/qpdf/qpdf))

## Installation

```bash
git clone https://github.com/mortolian/pdf-password-remover.git
cd pdf-password-remover
chmod +x install.sh
./install.sh
```

The installer will:

1. Install `qpdf` via Homebrew (if needed)
2. Install `pdf-unlock`, `pdf-password`, and `pdf-unlock-finder` to `~/.local/bin`
3. Copy the **Unlock PDFs** Quick Action to `~/Library/Services`

If `~/.local/bin` is not on your `PATH`, add to `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Enable the Quick Action: **System Settings → Privacy & Security → Extensions → Finder** (if prompted).

## Quick start

### 1. Store your password(s) in Keychain

```bash
pdf-password add          # name: default
pdf-password add work     # optional second password
pdf-password list         # shows names only, never the passwords
```

macOS may prompt once to allow Terminal (or the Quick Action) to access the Keychain.

### 2. Unlock PDFs

**Command line — current folder only:**

```bash
pdf-unlock ~/Documents/invoices
```

**Include all subfolders:**

```bash
pdf-unlock -r ~/Documents/invoices
```

**Replace originals** (creates `.bak` backup first):

```bash
pdf-unlock --in-place ~/Documents/invoices
```

**Dry run** (see what would happen):

```bash
pdf-unlock -n -r ~/Documents/invoices
```

### Enable the Quick Action (macOS 26 Tahoe)

Apple moved this setting. Try these in order:

1. **System Settings → General → Login Items & Extensions**
   - Scroll to **Extensions**
   - Click the **ⓘ** (info) button next to **Finder**
   - Turn on **Unlock PDFs**

2. **System Settings → Privacy & Security**
   - Scroll to the bottom → **Extensions** (under *Others*)
   - Click **Finder**
   - Turn on **Unlock PDFs**

3. Use **search** at the top of System Settings and type `Extensions` or `Unlock PDFs`.

If **Unlock PDFs** does not appear in the list:

```bash
open ~/Library/Services/Unlock\ PDFs.workflow
```

In Automator: **File → Save** (no changes needed). Then check the Finder extensions list again and restart Finder:

```bash
killall Finder
```

**Finder:** Select a folder → right-click → **Quick Actions** → **Unlock PDFs** → choose *This folder only* or *Include subfolders*.

If it is not under Quick Actions, try **Services** → **Unlock PDFs** (same action, older menu name).

## Where passwords are stored

| Location | Used? | Why |
|----------|-------|-----|
| **macOS Keychain** | Yes | Encrypted, OS-managed, supports multiple labels; best practice on Mac |
| `.env` / config files | No | Risk of accidental git commit |
| Command-line arguments | No | Visible in shell history and process list |
| This git repo | No | Never store secrets in version control |

Keychain service name: `pdf-password-remover`. Account name is the label you choose (`default`, `work`, etc.).

## Output behavior

| Mode | Result |
|------|--------|
| Default | `report.pdf` → `report-unlocked.pdf` |
| `--in-place` | Replaces `report.pdf`; backup at `report.pdf.bak` |
| `--output DIR` | Writes unlocked files under `DIR` |

Non-encrypted PDFs are skipped. Files already named `*-unlocked.pdf` are ignored.

## Automation

Use `pdf-unlock` in shell scripts, cron, or [launchd](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BFAutomationConcepts/Articles/BFDispatchQueues.html) jobs:

```bash
#!/bin/zsh
export PATH="$HOME/.local/bin:$PATH"
pdf-unlock -r -q /Users/you/Inbox/PDFs
```

`-q` prints only errors and the summary.

## Uninstall

```bash
./uninstall.sh
```

Removes CLI tools and the Quick Action. Keychain entries remain until you remove them:

```bash
pdf-password remove default
```

## Project layout

```
pdf-password-remover/
├── bin/
│   ├── pdf-unlock           # Main batch unlock CLI
│   ├── pdf-password         # Keychain password management
│   └── pdf-unlock-finder    # Finder Quick Action helper
├── quick-action/
│   └── Unlock PDFs.workflow # macOS Quick Action bundle
├── install.sh
├── uninstall.sh
├── README.md
├── SECURITY.md
└── LICENSE
```

## Security

See [SECURITY.md](SECURITY.md). Use only on PDFs you own or are authorized to decrypt.

## License

[MIT](LICENSE)
