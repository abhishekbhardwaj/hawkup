# Hawkup

Hawkup is an opinionated configuration script that transforms fresh ~~Ubuntu~~ Linux (Desktop/Server) installations into a modern development environment. Does the Terminal Setup only.

Supported OS:

- [x] Ubuntu 24.04+.
- [ ] Arch Linux
- [ ] Fedora

> Run as a regular sudo-enabled user on a fresh system.

## Quick Start

Run this from a fresh Ubuntu shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishekbhardwaj/hawkup/main/boot.sh)"
```

The bootstrapper will:
- Ensure `git` is installed
- Clone Hawkup into `~/.local/share/hawkup`
- Start the installer and guide you through a few choices

You will be prompted to reboot at the end so group memberships and shell config take effect.

## What It Installs

- Core terminal tools: `curl`, `git`, `unzip`, build essentials, `fzf`, `ripgrep`, `bat`, `eza`, `zoxide`, `plocate`, `fd` (via `fd-find`), ImageMagick, libvips, and more
- Shell config: replaces `~/.bashrc` and `~/.inputrc` (backs up existing files with `.bak`), and syncs `~/.config/bash/*` (aliases, prompt, functions)
- Docker: official Docker engine + Buildx/Compose, Docker group membership, and sane log rotation
- Databases (Dockerized, optional): Redis, MySQL 8.4, PostgreSQL 16
- Language runtimes (via `mise`): Ruby (+ Rails), Bun, Deno, Node.js (LTS), Go, PHP (+ Composer), Python, Elixir (Erlang), Rust, Java, Zig (+ ZLS)
- Terminal apps: Neovim (from upstream tarball) + LazyVim starter and theme; `lazygit`, `lazydocker`, `btop`, `fastfetch`, `gh` (GitHub CLI)
- Nerd Fonts: JetBrainsMono, FiraCode, Hack (customizable via `NERDFONTS_FONTS`)
- Tmux: config + TPM (tmux plugin manager) and common plugins

## During Install

- You’ll choose languages and databases via a simple TUI (uses `gum`; defaults are Bun + Node.js, and no databases selected).
- Nerd Fonts are chosen via a TUI as well; by default CascadiaMono, FiraMono, JetBrainsMono, and Meslo are pre-selected.
- You’ll be asked for your full name and email to configure global git identity
- Dotfiles are backed up once if they exist, then replaced with Hawkup defaults

## After Install

- Reboot when prompted (recommended) so:
  - Docker group membership activates (no `sudo` for `docker`)
  - New shell config and PATH are loaded
- After reboot, open a new terminal and verify:
  - `hawkup` is on PATH (provided by `~/.config/bash/shell`)
  - `docker run hello-world` works without `sudo`

## CLI

The `hawkup` helper lives in `~/.local/share/hawkup/bin` and is added to PATH by the shell config.

### System Management

```bash
hawkup update          # apt update/upgrade
hawkup upgrade         # apt update/upgrade + upgrade terminal apps
hawkup sync-configs    # re-sync dotfiles from this repo (backs up current)
hawkup migrate         # run repo migrations
hawkup nerdfonts ...   # manage Nerd Fonts (see below)
hawkup setup-tailscale # install Tailscale
# Deprecated alias; see AI section: hawkup install-ai
```

### AI Tools

Install AI tooling via the new subcommand:

```bash
# Default installs opencode
hawkup ai install

# Explicitly install opencode (via npm)
hawkup ai install opencode

# Install Claude Code
hawkup ai install claude-code
```

Notes:
- `opencode` installs the `opencode-ai` npm package. Requires Node.js/npm (e.g., via `mise`).
- `claude-code` runs: `curl -fsSL https://claude.ai/install.sh | bash`.
- Legacy command `hawkup install-ai` remains as a deprecated alias and currently installs `opencode`.

### Secrets

Hawkup manages secrets in `~/.secrets` (KEY=value). It is sourced automatically at shell startup.

```bash
hawkup secrets add OPENAI_API_KEY sk-xxxxx   # prompts if value omitted
hawkup secrets list                           # lists secret keys (not values)
hawkup secrets remove OPENAI_API_KEY

# Print export lines for all or specific secrets
hawkup secrets env                  # prints all exports
hawkup secrets env OPENAI_API_KEY   # prints one export

# Apply immediately to current shell
source ~/.secrets
# or
eval "$(hawkup secrets env)"
```

### Nerd Fonts Management

Hawkup includes a built-in Nerd Fonts manager for installing and managing patched fonts with icon support.

```bash
# List available fonts
hawkup nerdfonts list                    # Lists all available Nerd Fonts from latest release
hawkup nerdfonts list v3.4.0            # Lists fonts from specific version

# Install fonts
hawkup nerdfonts install JetBrainsMono   # Install a single font
hawkup nerdfonts install "JetBrainsMono" "FiraCode" "Hack"  # Install multiple fonts

# Update (force reinstall) fonts
hawkup nerdfonts update JetBrainsMono    # Force reinstall of a font

# Pin to specific version
NERDFONTS_VERSION=v3.4.0 hawkup nerdfonts install CascadiaMono
```

**Font Installation Details:**
- Fonts are installed to `~/.local/share/fonts/NerdFonts/` by default
- Each font is installed in its own subdirectory (e.g., `JetBrainsMono/`, `FiraCode/`)
- Fonts are automatically detected if they already exist (no duplicate downloads)
- Use `hawkup nerdfonts update` to force reinstall/update fonts
- Font cache is automatically refreshed after installation (if `fc-cache` is available)

**Customization Options:**
```bash
# Change install directory
NERDFONTS_DIR="/custom/path" hawkup nerdfonts install Hack

# Force reinstall (bypass existing font check)
NERDFONTS_FORCE=1 hawkup nerdfonts install JetBrainsMono

# Pin to specific release version
NERDFONTS_VERSION=v3.3.0 hawkup nerdfonts install FiraCode
```

**Font Name Aliases:**
The tool automatically normalizes common font name variations:
- `CaskaydiaMono` → `CascadiaMono`
- `MesloLGS`, `MesloLGSNF` → `Meslo`
- `Symbols`, `SymbolsOnly` → `NerdFontsSymbolsOnly`

**Using Nerd Fonts:**
After installation, configure your terminal emulator to use one of the installed fonts:
1. Open your terminal preferences/settings
2. Change the font to one of: JetBrainsMono Nerd Font, FiraCode Nerd Font, Hack Nerd Font, etc.
3. Icons will now display correctly in tools like `eza --icons`, `lazygit`, `neovim`, and `starship`

## Manual Install (alternative)

```bash
# 1) Clone to the expected location
git clone https://github.com/abhishekbhardwaj/hawkup.git ~/.local/share/hawkup

# 2) Start the installer
bash ~/.local/share/hawkup/install.sh
```

## Requirements

- Ubuntu 24.04+ (checked during install)
- x86 CPU (x86_64/i686); ARM is not supported yet
- Internet access (downloads packages and upstream binaries)
- `sudo` privileges

## Troubleshooting & Notes

- Non-root: Run as a normal user with `sudo`, not as root, so Docker group membership is applied to your user.
- Backups: Your original `~/.bashrc`, `~/.inputrc`, and `~/.config/bash` are saved as `.bak` if they existed. If you later run `hawkup sync-configs`, your current versions are backed up again before re-applying the repo defaults.
- APT/dpkg errors: If you see "E: subprocess /usr/bin/dpkg returned an error code (1)" or "no apport report written ... followup error", your APT state is broken from a previous failure. Repair and rerun:
  ```bash
  sudo -v
  sudo dpkg --configure -a
  sudo apt-get -f install
  sudo apt-get clean
  sudo apt-get update
  sudo apt-get install -y git
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishekbhardwaj/hawkup/main/boot.sh)"
  ```

## Headless / Noninteractive Install

You can run Hawkup without any interactive prompts by pre-setting a few environment variables and then invoking the normal installer. This is useful for servers, CI images, or provisioning tools.

Example using the bootstrapper:

```bash
HAWKUP_USER_NAME="Jane Doe" \
HAWKUP_USER_EMAIL="jane@example.com" \
HAWKUP_FIRST_RUN_LANGUAGES="Bun,Node.js,Rust" \
HAWKUP_FIRST_RUN_DBS="PostgreSQL,Redis" \
NERDFONTS_FONTS="JetBrainsMono FiraCode" \
HAWKUP_SKIP_REBOOT=1 \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/abhishekbhardwaj/hawkup/main/boot.sh)"
```

If you have already cloned the repo:

```bash
export HAWKUP_DIR="$HOME/.local/share/hawkup"  # or your clone path

export HAWKUP_USER_NAME="Jane Doe"
export HAWKUP_USER_EMAIL="jane@example.com"

export HAWKUP_FIRST_RUN_LANGUAGES="Bun,Node.js,Rust"   # Bun, Deno, Elixir, Go, Java, Node.js, PHP, Python, Ruby, Rust, Zig
export HAWKUP_FIRST_RUN_DBS="MySQL,PostgreSQL,Redis"   # any subset

export NERDFONTS_FONTS="JetBrainsMono FiraCode Hack"   # space-separated font names
# Optional: export NERDFONTS_VERSION=v3.4.0            # pin Nerd Fonts release
# Optional: export HAWKUP_SKIP_NERDFONTS=1             # skip Nerd Fonts step entirely
# Optional: export HAWKUP_SKIP_TMUX=1                  # skip tmux + TPM plugins
# Optional: export HAWKUP_SKIP_REBOOT=1                # do not reboot at the end

bash "$HAWKUP_DIR/install.sh"
```

Installer knobs (can all be set via `export`):

- `HAWKUP_DIR`: path where the repo lives. Defaults to `~/.local/share/hawkup` (used by both installer and `bin/hawkup`).
- `HAWKUP_USER_NAME` / `HAWKUP_USER_EMAIL`: git identity used by `install/terminal/base/git.sh`. If unset, you are prompted once via `gum`.
- `HAWKUP_FIRST_RUN_LANGUAGES`: comma- or space-separated list of languages to install via `mise`. Valid values: `Bun`, `Deno`, `Elixir`, `Go`, `Java`, `Node.js`, `PHP`, `Python`, `Ruby`, `Rust`, `Zig`.
- `HAWKUP_FIRST_RUN_DBS`: comma-separated list of databases (`MySQL`, `PostgreSQL`, `Redis`). Controls which Docker database containers are created.
- `NERDFONTS_FONTS`: space-separated font names to install (e.g. `JetBrainsMono FiraCode Hack`). If explicitly set to an empty string (`NERDFONTS_FONTS=""`), the Nerd Fonts install step is skipped.
- `NERDFONTS_VERSION`: Nerd Fonts release tag (e.g. `v3.4.0`). Defaults to the latest release if unset.
- `NERDFONTS_DIR`: directory where fonts are installed. Defaults to `~/.local/share/fonts/NerdFonts`.
- `NERDFONTS_FORCE`: set to `1` to force reinstalling fonts even if they already exist in `NERDFONTS_DIR`.
- `HAWKUP_SKIP_NERDFONTS`: set to `1` to skip Nerd Fonts installation entirely.
- `HAWKUP_SKIP_TMUX`: set to `1` to skip tmux installation and TPM plugin bootstrap (handy in pure server/CI environments).
- `HAWKUP_SKIP_REBOOT`: set to `1` to suppress the final reboot prompt at the end of the installer.
- `SECRETS_FILE`: optional path to the secrets file used by `hawkup secrets`. Defaults to `~/.secrets`.

## Inspirations

- Omakub: https://github.com/basecamp/omakub

## Architecture

- `boot.sh`: remote entrypoint used by the curl one-liner. Ensures apt/dpkg are in a sane state, installs `git`, clones the repo into `~/.local/share/hawkup`, and then sources `install.sh`.
- `install.sh`: main installer orchestrator. Sets `HAWKUP_DIR`, wires in the apt helper, runs OS/arch checks, collects first-run choices via `gum`, and then delegates to `install/terminal.sh` followed by post-flight steps.
- Pre-flight (`install/pre-flight/*.sh`):
  - `check-version.sh`: aborts if the host is not Ubuntu 24.04+ on x86.
  - `gum.sh`: installs the `gum` TUI binary on minimal images.
  - `first-run-choices.sh`: captures languages, databases, and Nerd Fonts selection, honoring pre-set `HAWKUP_FIRST_RUN_*` and `NERDFONTS_*` variables.
  - `identification.sh`: captures `HAWKUP_USER_NAME` and `HAWKUP_USER_EMAIL` for git configuration.
- Core terminal installer (`install/terminal.sh`):
  - Installs baseline packages and syncs dotfiles from `configs/` into your home directory (`.bashrc`, `.inputrc`, `~/.config/bash`).
  - Ensures `~/.secrets` exists (using `install/lib/secrets.sh`) and loads the shell `~/.config/bash/shell` file for the current session.
  - Runs all `install/terminal/base/*.sh` installers (Docker, terminfo, `mise`, Nerd Fonts, tmux, vim, etc.) followed by `install/terminal/base/database.sh` and then all `install/terminal/apps/*.sh` installers (Neovim, `btop`, `fastfetch`, `gh`, `lazygit`, `lazydocker`, AI tooling, etc.).
- Shared libraries (`install/lib/*.sh`):
  - `apt.sh`: robust apt/dpkg lock handling via `wait_for_apt`.
  - `nerdfonts.sh`: Nerd Fonts HTTP and unzip helpers used by both the installer and `bin/hawkup nerdfonts`.
  - `secrets.sh`: secrets file helpers backing the `hawkup secrets` subcommands.
- Post-install extras:
  - `install/post-flight/zsh-mounts.sh`: optionally hides ZFS pools from the Ubuntu dock via a udev rule on ZFS systems.
  - `migrations/`: timestamped migration scripts that run after repo upgrades via `hawkup migrate`.
- CLI (`bin/hawkup`):
  - Provides `update`, `upgrade`, `migrate`, `sync-configs`, `setup-tailscale`, `ai`, `secrets`, and `nerdfonts` subcommands.
  - Treats the clone directory as `HAWKUP_DIR` (defaulting to `~/.local/share/hawkup`) and reuses the same libraries as the installer so behaviors stay consistent over time.
