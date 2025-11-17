# Hawkup

Hawkup turns a fresh Ubuntu machine into a modern, terminal‑focused development environment: shell, tools, runtimes, Neovim, Docker, databases, fonts, and a small CLI to keep it all up to date.

- **Supported OS:** Ubuntu 24.04+ (Desktop/Server)
- **Architecture:** x86 (`x86_64` / `i686`) only (checked during install)
- **Scope:** terminal and CLI tooling only (no desktop apps)

> Run as a regular sudo-enabled user on a fresh system.

## Quick Start

From a fresh Ubuntu 24.04+ shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishekbhardwaj/hawkup/main/boot.sh)"
```

The bootstrapper will:
- Ensure `git` is installed (fixing apt/dpkg locks first)
- Clone Hawkup into `~/.local/share/hawkup`
- Run the installer and guide you through a few choices

You’ll be prompted to reboot at the end so group memberships and shell config take effect.

## What You Get

- **Terminal baseline**
  - `curl`, `git`, `unzip`, build-essential, `fzf`, `ripgrep`, `bat` (via `batcat`), `eza`, `zoxide`, `plocate`, `fd` (via `fd-find`), ImageMagick, libvips, `mupdf`, `pipx`, and more.

- **Shell & prompt (Bash)**
  - Replaces `~/.bashrc` and `~/.inputrc` with tuned defaults (backs up existing files as `.bak`).
  - Syncs `~/.config/bash/*` (aliases, prompt, functions, init).
  - Starship prompt configured via `~/.config/starship.toml`.
  - `HAWKUP_PATH`/`PATH` wiring so `hawkup` is on PATH.
  - Secrets auto-loaded from `~/.secrets` if present.

- **Languages via `mise`**
  - Installs `mise` and any languages you select: `Bun`, `Deno`, `Elixir` (with Erlang), `Go`, `Java`, `Node.js` (LTS), `PHP` (+ Composer), `Python`, `Ruby` (+ Rails), `Rust`, `Zig` (+ ZLS).

- **Docker & databases**
  - Official Docker engine + Buildx/Compose, user added to `docker` group, conservative log rotation (`/etc/docker/daemon.json`).
  - Optional Dockerized databases: Redis (`redis:7`), MySQL 8.4 (`mysql:8.4`), PostgreSQL 16 (`postgres:16`) with local client libs.

- **Editor & terminal apps**
  - Neovim from upstream tarball, with LazyVim starter, Catppuccin theme, transparency, tweaked options, and Neo-tree enabled.
  - `lazygit`, `lazydocker`, `btop` (with Catppuccin theme), `fastfetch` (with custom config), and GitHub CLI (`gh`).
  - `tldr` via `pipx` for simplified man pages.

- **Fonts & tmux**
  - Nerd Fonts (JetBrainsMono, FiraCode, Hack by default; configurable).
  - Terminfo aliases for common modern terminals (Ghostty, Kitty, Alacritty, WezTerm, `tmux-256color` fallback).
  - Tmux config (`~/.tmux.conf`) with Catppuccin theme and TPM plugins, installed and bootstrapped automatically (skippable).

- **Hawkup CLI**
  - `hawkup` helper for updates, migrations, config syncing, Nerd Fonts, secrets, Tailscale, and AI tooling.

## Install Flow

### During Install

- OS/arch check ensures Ubuntu 24.04+ on x86 before proceeding.
- You choose:
  - Programming languages (via `gum` TUI; defaults: Bun + Node.js).
  - Databases (Redis/MySQL/PostgreSQL) to run in Docker.
  - Nerd Fonts to install (defaults: CascadiaMono, FiraMono, JetBrainsMono, Meslo).
- You’re asked once for full name and email to configure global git identity.
- Existing dotfiles (`.bashrc`, `.inputrc`, `~/.config/bash`) are backed up once and replaced with Hawkup defaults.
- `~/.secrets` is created securely if missing and wired into the shell.

### After Install

- Reboot when prompted (recommended) so:
  - Docker group membership activates (no `sudo` for `docker`).
  - Shell config, PATH, and terminfo tweaks are loaded everywhere.
- After reboot, open a new terminal and verify:
  - `hawkup` works and is on PATH.
  - `docker run hello-world` works without `sudo`.

## Requirements

- Ubuntu 24.04+ (enforced by `install/pre-flight/check-version.sh`).
- x86 CPU (`x86_64` or `i686`); ARM is not supported yet.
- Internet access (downloads packages, binaries, fonts, and configs).
- `sudo` privileges for package and system changes.

## Manual Install (alternative)

If you don’t want to use the one-liner:

```bash
# 1) Clone to the expected location
git clone https://github.com/abhishekbhardwaj/hawkup.git ~/.local/share/hawkup

# 2) Start the installer
HAWKUP_DIR="$HOME/.local/share/hawkup" bash ~/.local/share/hawkup/install.sh
```

## Headless / Noninteractive Install

You can run Hawkup without prompts by exporting a few environment variables and then running the normal installer. This is useful for servers, CI images, or provisioning tools.

### Example with the bootstrapper

```bash
HAWKUP_USER_NAME="Jane Doe" \
HAWKUP_USER_EMAIL="jane@example.com" \
HAWKUP_FIRST_RUN_LANGUAGES="Bun,Node.js,Rust" \
HAWKUP_FIRST_RUN_DBS="PostgreSQL,Redis" \
NERDFONTS_FONTS="JetBrainsMono FiraCode" \
HAWKUP_SKIP_REBOOT=1 \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishekbhardwaj/hawkup/main/boot.sh)"
```

### Example when the repo is already cloned

```bash
export HAWKUP_DIR="$HOME/.local/share/hawkup"  # or your clone path

export HAWKUP_USER_NAME="Jane Doe"
export HAWKUP_USER_EMAIL="jane@example.com"

export HAWKUP_FIRST_RUN_LANGUAGES="Bun,Node.js,Rust"   # subset of: Bun, Deno, Elixir, Go, Java, Node.js, PHP, Python, Ruby, Rust, Zig
export HAWKUP_FIRST_RUN_DBS="MySQL,PostgreSQL,Redis"   # any subset

export NERDFONTS_FONTS="JetBrainsMono FiraCode Hack"   # space-separated font names
# Optional: export NERDFONTS_VERSION=v3.4.0            # pin Nerd Fonts release
# Optional: export HAWKUP_SKIP_NERDFONTS=1             # skip Nerd Fonts step entirely
# Optional: export HAWKUP_SKIP_TMUX=1                  # skip tmux + TPM plugins
# Optional: export HAWKUP_SKIP_REBOOT=1                # do not reboot at the end

bash "$HAWKUP_DIR/install.sh"
```

### Installer knobs (all are `export`‑able)

- `HAWKUP_DIR` – path where the repo lives. Defaults to `~/.local/share/hawkup` (used by both installer and `bin/hawkup`).
- `HAWKUP_USER_NAME` / `HAWKUP_USER_EMAIL` – git identity used by `install/terminal/base/git.sh`. If unset, you’re prompted once via `gum`.
- `HAWKUP_FIRST_RUN_LANGUAGES` – comma‑ or space‑separated list of languages to install via `mise` (`Bun`, `Deno`, `Elixir`, `Go`, `Java`, `Node.js`, `PHP`, `Python`, `Ruby`, `Rust`, `Zig`).
- `HAWKUP_FIRST_RUN_DBS` – comma‑separated list of databases (`MySQL`, `PostgreSQL`, `Redis`); controls which Docker containers are created.
- `NERDFONTS_FONTS` – space‑separated font names to install (for example `JetBrainsMono FiraCode Hack`). If explicitly set to an empty string (`NERDFONTS_FONTS=""`), the Nerd Fonts install step is skipped.
- `NERDFONTS_VERSION` – Nerd Fonts release tag (for example `v3.4.0`). Defaults to the latest release if unset.
- `NERDFONTS_DIR` – directory where fonts are installed. Defaults to `~/.local/share/fonts/NerdFonts`.
- `NERDFONTS_FORCE` – set to `1` to force reinstalling fonts even if they already exist in `NERDFONTS_DIR`.
- `HAWKUP_SKIP_NERDFONTS` – set to `1` to skip Nerd Fonts installation entirely.
- `HAWKUP_SKIP_TMUX` – set to `1` to skip tmux installation and TPM plugin bootstrap (handy in pure server/CI environments).
- `HAWKUP_SKIP_REBOOT` – set to `1` to suppress the final reboot prompt.

## Hawkup CLI

The `hawkup` helper lives in `~/.local/share/hawkup/bin` and is added to PATH by the Bash config (`~/.config/bash/shell`).

### System management

```bash
hawkup update          # apt-get update/upgrade
hawkup upgrade         # apt-get update/upgrade + rerun terminal app installers
hawkup sync-configs    # re-sync dotfiles from this repo (backs up current)
hawkup migrate         # run repo migrations (migrations/*.sh)
hawkup setup-tailscale # install Tailscale (official script)
hawkup enable-ssh      # detect ssh/sshd service, enable it, and start it now
```

### Nerd Fonts (CLI)

```bash
hawkup nerdfonts list                 # list available fonts from latest Nerd Fonts release
hawkup nerdfonts list v3.4.0         # list fonts from a specific release

hawkup nerdfonts install JetBrainsMono        # install one font
hawkup nerdfonts install "JetBrainsMono" "FiraCode" "Hack"  # install multiple fonts

hawkup nerdfonts update JetBrainsMono # force reinstall a font
NERDFONTS_VERSION=v3.4.0 hawkup nerdfonts install CascadiaMono  # pin to a release
```

Details:
- Installed to `~/.local/share/fonts/NerdFonts` by default (one subdirectory per font).
- Existing font directories are detected to avoid duplicate downloads unless `NERDFONTS_FORCE=1`.
- Common aliases are normalized, for example:
  - `CaskaydiaMono` → `CascadiaMono`
  - `MesloLGS`, `MesloLGSNF` → `Meslo`
  - `Symbols`, `SymbolsOnly` → `NerdFontsSymbolsOnly`
- Font cache is refreshed automatically if `fc-cache` is available.

After installation, configure your terminal emulator to use a Nerd Font (for example *JetBrainsMono Nerd Font*), and icons will show up in tools like `eza --icons`, `lazygit`, `neovim`, and `starship`.

### Secrets (`~/.secrets`)

Hawkup manages a simple environment‑variable file at `~/.secrets` and loads it automatically from Bash.

```bash
hawkup secrets add OPENAI_API_KEY sk-xxxxx   # prompts if value omitted
hawkup secrets list                          # list secret keys (not values)
hawkup secrets remove OPENAI_API_KEY

# Print export lines for all or specific secrets
hawkup secrets env                  # all exports
hawkup secrets env OPENAI_API_KEY   # single export

# Apply immediately to the current shell
source ~/.secrets
# or
eval "$(hawkup secrets env)"
```

- Secrets are stored as `export KEY=VALUE` in `~/.secrets`.
- Writes are atomic and file permissions are hardened to `600`.
- A backup (`~/.secrets.bak` or timestamped variants) is created from the installer when needed.

### AI tools

```bash
hawkup ai install            # default: install opencode-ai via npm
hawkup ai install opencode   # explicitly install opencode-ai
hawkup ai install claude-code
```

Notes:
- `opencode` installs the `opencode-ai` npm package, so Node.js/npm must be available (for example via `mise`).
- `claude-code` runs `curl -fsSL https://claude.ai/install.sh | bash`.

## How It Works (Layout)

- `boot.sh` – remote entrypoint used by the curl one‑liner. Ensures apt/dpkg are in a sane state (via `wait_for_apt`), installs `git`, clones into `~/.local/share/hawkup`, then sources `install.sh`.
- `install.sh` – main installer orchestrator. Sets `HAWKUP_DIR`, wires in the apt helper, runs OS/arch checks, gathers first‑run choices with `gum`, then calls `install/terminal.sh` and post‑flight steps.
- `install/pre-flight/*.sh` – early checks and prompts:
  - `check-version.sh` – enforces Ubuntu 24.04+ on x86.
  - `gum.sh` – installs the `gum` TUI binary on minimal images.
  - `first-run-choices.sh` – captures languages, databases, and Nerd Fonts (honoring `HAWKUP_FIRST_RUN_*` and `NERDFONTS_*` env vars).
  - `identification.sh` – collects `HAWKUP_USER_NAME` / `HAWKUP_USER_EMAIL` for git.
- `install/terminal.sh` – core terminal installer:
  - Installs baseline packages and syncs dotfiles from `configs/` into your home directory.
  - Ensures `~/.secrets` exists (via `install/lib/secrets.sh`) and loads `~/.config/bash/shell` into the current session.
  - Runs all `install/terminal/base/*.sh` (Docker, terminfo, `mise`, Nerd Fonts, git, tmux, vim, etc.), then `install/terminal/base/database.sh`, then all `install/terminal/apps/*.sh` (Neovim, `btop`, `fastfetch`, `gh`, `lazygit`, `lazydocker`, AI tooling).
- `install/lib/*.sh` – shared helpers:
  - `apt.sh` – robust apt/dpkg lock handling via `wait_for_apt`.
  - `nerdfonts.sh` – Nerd Fonts HTTP, parsing, and unzip helpers used by the installer and `hawkup nerdfonts`.
  - `secrets.sh` – helpers providing `secrets_*` functions backing `hawkup secrets`.
- `install/post-flight/zsh-mounts.sh` – optional tweak that hides ZFS system pools from the Ubuntu dock using a udev rule (no effect if ZFS isn’t present).
- `configs/` – all the shipped dotfiles:
  - `configs/.bashrc`, `.inputrc`, `.tmux.conf`, `.vimrc`.
  - `configs/bash/*` – aliases, functions, prompt, shell, and init logic.
  - `configs/fastfetch`, `configs/btop`, `configs/nvim`, `configs/starship.toml`, `configs/terminfo/aliases.src`.
- `bin/hawkup` – the CLI wrapper for updates, migrations, config syncing, Tailscale, Nerd Fonts, secrets, and AI tooling.
- `migrations/` – timestamped migration scripts run by `hawkup migrate` (plus `create-migration.sh` for authoring new migrations).

## Troubleshooting & Notes

- **Run as non‑root** – use a normal user with `sudo` so Docker group membership and dotfile ownership apply to your account.
- **Dotfile backups** – your existing `~/.bashrc`, `~/.inputrc`, and `~/.config/bash` are backed up as `.bak` once. Later `hawkup sync-configs` calls back up your current versions again before reapplying defaults.
- **APT/dpkg errors** – if you see errors like `E: subprocess /usr/bin/dpkg returned an error code (1)` or “no apport report written … followup error”, your apt state is likely broken from an earlier failure. Repair and rerun:
  ```bash
  sudo -v
  sudo dpkg --configure -a
  sudo apt-get -f install
  sudo apt-get clean
  sudo apt-get update
  sudo apt-get install -y git
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishekbhardwaj/hawkup/main/boot.sh)"
  ```

## Inspirations

- Omakub: https://github.com/basecamp/omakub
