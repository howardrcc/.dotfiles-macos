# CLAUDE.md

## Project Overview
Migrating Howard's macOS system from Homebrew to Nix using nix-darwin + Home Manager + Flakes. Config lives in `~/.dotfiles/`.

## System Details
- **Hostname:** Mac (darwinConfigurations."Mac")
- **Username:** howard
- **Architecture:** aarch64-darwin (Apple Silicon)
- **Nix installer:** Determinate Systems (requires `nix.enable = false;` in nix-darwin config)

## Current State
Full modular Nix migration complete and applied. All modules active.

## Key Config Decisions
- **Config repo:** `~/.dotfiles/` (not `~/.config/nix-darwin/`)
- **Rebuild alias:** `alias update="sudo darwin-rebuild switch --flake ~/.dotfiles"`
- **GUI apps:** Homebrew Casks, managed declaratively via `modules/darwin/homebrew.nix`
- **CLI tools:** Managed via Nix (`modules/darwin/packages.nix`)
- **Shell:** Zsh via `programs.zsh` in Home Manager; prompt is Starship
- **Terminal:** Ghostty (via Homebrew cask; config at `modules/home/terminal.nix`)
- **nix.enable:** Must be `false` because Determinate Systems manages the Nix daemon
- **system.primaryUser:** Must be set to `"howard"` for user-level defaults to apply (new nix-darwin requirement)

## Rebuild Commands
```bash
# Normal rebuild
sudo darwin-rebuild switch --flake ~/.dotfiles

# After flake.nix input changes
nix flake update --flake ~/.dotfiles
sudo darwin-rebuild switch --flake ~/.dotfiles
```

## Repo Structure (current)
```
~/.dotfiles/
├── flake.nix
├── flake.lock
├── CLAUDE.md
├── hosts/Mac/default.nix       # Host entrypoint, imports all modules
├── modules/
│   ├── darwin/
│   │   ├── system.nix          # macOS defaults (Dock, Finder, trackpad, etc.)
│   │   ├── packages.nix        # CLI tools via environment.systemPackages
│   │   ├── homebrew.nix        # Declarative Homebrew casks + brews
│   │   └── fonts.nix           # Nerd Fonts via nixpkgs
│   └── home/
│       ├── default.nix         # Home Manager entrypoint
│       ├── shell.nix           # Zsh + Starship + aliases + env vars
│       ├── git.nix             # programs.git + programs.delta
│       ├── terminal.nix        # Ghostty config via xdg.configFile
│       ├── aerospace.nix       # AeroSpace TOML via xdg.configFile
│       ├── aerospace/
│       │   └── aerospace.toml  # AeroSpace config (source of truth)
│       ├── karabiner.nix       # Karabiner JSON via xdg.configFile
│       └── sketchybar/
│           ├── default.nix     # Lua config dir via xdg.configFile
│           └── config/         # All SketchyBar Lua files + compiled binaries
├── karabiner/
│   └── karabiner.json          # Karabiner-Elements config (source of truth)
└── archive/                    # Legacy Homebrew-based dotfiles (reference only)
```

## Gotchas
- Don't use `sudo` for `nix build` or `nix run` — only for `darwin-rebuild switch`
- Determinate Nix conflicts with nix-darwin's Nix management — always keep `nix.enable = false`
- `system.primaryUser = "howard"` is required for user-level defaults (Dock, Finder, NSGlobalDomain, homebrew)
- Home Manager symlinks configs into `~/.config/` even though the repo is at `~/.dotfiles/`
- Git config goes to `~/.config/git/config` (not `~/.gitconfig`) in this version of Home Manager
- SketchyBar event provider binaries (`cpu_load`, `network_load`) are compiled aarch64 binaries checked in to `modules/home/sketchybar/config/helpers/event_providers/*/bin/` — rebuild by running `helpers/install.sh` if they break after macOS upgrades
- `font-sketchybar-app-font` must not have a conflicting manually-installed TTF at `~/Library/Fonts/sketchybar-app-font.ttf`
- SketchyBar launchd service PATH is only `/opt/homebrew/bin:...` — Nix packages are invisible to it. Keep `lua` in `homebrew.brews` (not just Nix packages) so the service can execute the Lua config
- SketchyBar event provider binaries (`helpers/event_providers/*/bin/`) must NOT be Nix-managed symlinks — `helpers/init.lua` recompiles them with `make` on every startup. They're gitignored and rebuilt fresh each run
- `shaunsingh/sfmono-nerd-font-ligaturized` tap can't be untapped while `font-sf-mono-nerd-font-ligaturized` cask is installed (harmless warning)
- `programs.zsh.initExtra` is deprecated — use `initContent` instead
- `nixfmt-rfc-style` package is deprecated — use `nixfmt` (same thing now)
