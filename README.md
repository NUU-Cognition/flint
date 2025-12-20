# Flint

A cognitive mesh CLI for structured knowledge work.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/NUU-Cognition/flint/main/install.sh | bash
```

### Requirements

- **Node.js 20+** — [Download](https://nodejs.org)
- **macOS or Linux** (Windows users: use WSL)

### What it does

1. Checks for Node 20+
2. Downloads the latest release
3. Installs to `~/.nuucognition/flint/` (user data stays in `~/.flint/`)
4. Adds `flint` command to your PATH

## Update

Re-run the install command:

```bash
curl -fsSL https://raw.githubusercontent.com/NUU-Cognition/flint/main/install.sh | bash
```

## Uninstall

```bash
rm -rf ~/.nuucognition/flint
sudo rm /usr/local/bin/flint  # or ~/.local/bin/flint
```

Note: Your flint data (`~/.flint/`) is preserved.

## Verify

```bash
flint --version
```

## Documentation

See the [NUU Cognition](https://github.com/NUU-Cognition) organization for more.
