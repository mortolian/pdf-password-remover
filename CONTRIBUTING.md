# Contributing

Thanks for contributing. A few guidelines:

1. **Never commit passwords or Keychain exports.** PRs that add secrets will be closed.
2. Keep shell scripts compatible with macOS default `/bin/bash` and `/bin/zsh`.
3. Run [ShellCheck](https://www.shellcheck.net/) on changed scripts: `shellcheck bin/*`
4. Update `README.md` if you change user-facing behavior.

## Development setup

```bash
git clone https://github.com/mortolian/pdf-password-remover.git
cd pdf-password-remover
chmod +x install.sh bin/*
./install.sh
```

## Pull requests

- One logical change per PR when possible
- Describe behavior changes and how you tested on macOS
