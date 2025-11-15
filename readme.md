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

- You’ll choose languages and databases via a simple TUI (uses `gum`)
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
hawkup sync-configs    # re-sync dotfiles from this repo
hawkup setup-tailscale # install Tailscale
hawkup install-ai      # install opencode-ai + Claude CLI (requires npm)
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
- Backups: Your original `~/.bashrc`, `~/.inputrc`, and `~/.config/bash` are saved as `.bak` if they existed.
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


## Inspirations

- Omakub: https://github.com/basecamp/omakub
