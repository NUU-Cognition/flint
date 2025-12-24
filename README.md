# Flint

A cognitive mesh CLI for structured knowledge work.

## Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/NUU-Cognition/flint/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/NUU-Cognition/flint/main/install.ps1 | iex
```

### Windows (Git Bash / WSL)

```bash
curl -fsSL https://raw.githubusercontent.com/NUU-Cognition/flint/main/install.sh | bash
```

### Requirements

- **Node.js 20+** — [Download](https://nodejs.org)
- **macOS, Linux, or Windows**

### What it does

1. Checks for Node 20+
2. Downloads the latest release
3. Installs to `~/.flint` (Unix) or `%USERPROFILE%\.flint` (Windows)
4. Adds `flint` command to your PATH

## Update

Re-run the install command for your platform (see Install section above).

## Uninstall

### macOS / Linux

```bash
rm -rf ~/.flint
sudo rm /usr/local/bin/flint  # or ~/.local/bin/flint
```

### Windows (PowerShell)

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.flint"
# Then manually remove from PATH via System Environment Variables
```

## Verify

```bash
flint --version
```

## Documentation

See the [NUU Cognition](https://github.com/NUU-Cognition) organization for more.
