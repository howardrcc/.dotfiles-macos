# Brew → Nix Migration Spec

**Goal:** Declaratively manage macOS system settings, applications, window management (AeroSpace), status bar (SketchyBar), and all tooling via Nix — replacing Homebrew as the primary package manager.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                  flake.nix                       │
│  (single entrypoint, pins all dependencies)      │
├────────────────────┬────────────────────────────┤
│   nix-darwin       │      home-manager           │
│                    │   (as nix-darwin module)     │
├────────────────────┼────────────────────────────┤
│ • macOS defaults   │ • Dotfiles (zsh, git, etc) │
│ • System packages  │ • User packages            │
│ • Services/daemons │ • App configs              │
│ • Fonts            │ • SketchyBar config        │
│ • Homebrew Casks   │ • AeroSpace config         │
│   (via nix-darwin) │ • Shell environment        │
└────────────────────┴────────────────────────────┘
```

**Key tools:**

| Tool | Purpose |
|---|---|
| [Nix](https://nixos.org/) | Package manager & build system |
| [nix-darwin](https://github.com/LnL7/nix-darwin) | Declarative macOS system configuration (like NixOS, but for Mac) |
| [Home Manager](https://github.com/nix-community/home-manager) | User-level dotfiles & app config management |
| [Flakes](https://wiki.nixos.org/wiki/Flakes) | Reproducible dependency pinning via `flake.nix` + `flake.lock` |

---

## Repository Structure

```
~/.config/nix-darwin/
├── flake.nix                 # Entrypoint: inputs, outputs, system config
├── flake.lock                # Pinned dependency versions
├── hosts/
│   └── <hostname>/
│       ├── default.nix       # Host-specific nix-darwin config
│       └── hardware.nix      # Architecture (aarch64-darwin / x86_64-darwin)
├── modules/
│   ├── darwin/
│   │   ├── system.nix        # macOS defaults (Dock, Finder, etc.)
│   │   ├── packages.nix      # System-level packages
│   │   ├── homebrew.nix      # Homebrew Cask bridge (GUI apps)
│   │   ├── fonts.nix         # Font management
│   │   └── services.nix      # Launch daemons / agents
│   └── home/
│       ├── default.nix       # Home Manager entrypoint
│       ├── shell.nix         # Zsh, starship, aliases, env vars
│       ├── git.nix           # Git configuration
│       ├── terminal.nix      # Terminal emulator config (WezTerm/Alacritty/Kitty)
│       ├── sketchybar/
│       │   ├── default.nix   # SketchyBar package + service
│       │   └── config/       # SketchyBar lua/shell config files
│       ├── aerospace.nix     # AeroSpace tiling WM config
│       └── dev.nix           # Dev tools (languages, LSPs, editors)
└── overlays/                 # Custom package patches if needed
    └── default.nix
```

---

## Phase 1: Bootstrap Nix + nix-darwin

### 1.1 Install Nix (Determinate Systems installer recommended)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install
```

> The Determinate Systems installer enables flakes by default, handles macOS quirks, and provides a clean uninstall path.

### 1.2 Bootstrap nix-darwin

```bash
# Initial build (first time only)
nix run nix-darwin -- switch --flake ~/.config/nix-darwin
```

After first run, rebuild with:
```bash
darwin-rebuild switch --flake ~/.config/nix-darwin
```

### 1.3 Skeleton `flake.nix`

```nix
{
  description = "Howard's macOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: for declarative Homebrew Cask management
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }: {
    darwinConfigurations."<HOSTNAME>" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # or x86_64-darwin
      modules = [
        ./hosts/<hostname>/default.nix
        ./modules/darwin/system.nix
        ./modules/darwin/packages.nix
        ./modules/darwin/homebrew.nix
        ./modules/darwin/fonts.nix
        ./modules/darwin/services.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."<USERNAME>" = import ./modules/home;
        }

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "<USERNAME>";
          };
        }
      ];
    };
  };
}
```

---

## Phase 2: macOS System Settings (`system.nix`)

nix-darwin can set most `defaults write` values declaratively:

```nix
{ pkgs, ... }: {

  # System-level settings
  system.defaults = {

    # Dock
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.4;
      mru-spaces = false;           # Don't rearrange Spaces
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
      persistent-apps = [];         # Clear Dock apps (manage via AeroSpace)
      # wvous-* for hot corners if desired
    };

    # Finder
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;      # Show hidden files
      FXDefaultSearchScope = "SCcf"; # Search current folder
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv"; # Column view
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    # Global / NSGlobalDomain
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      "com.apple.swipescrolldirection" = true;
    };

    # Trackpad
    trackpad = {
      Clicking = true;               # Tap to click
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # Login window
    loginwindow = {
      GuestEnabled = false;
    };

    # Custom defaults not covered by nix-darwin options
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };

  # Hostname
  networking.hostName = "<HOSTNAME>";

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
```

---

## Phase 3: Package Management

### 3.1 CLI Tools via Nix (`packages.nix`)

```nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Core CLI
    coreutils
    curl
    wget
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    yq
    tree
    htop
    btop
    tmux
    zoxide

    # Dev
    git
    gh
    neovim
    lazygit
    direnv
    devenv

    # Nix tools
    nil              # Nix LSP
    nixfmt-rfc-style # Nix formatter
    nix-tree

    # Cloud / Infra
    kubectl
    terraform
    azure-cli

    # Data
    python3
    uv               # Python package manager
    duckdb
  ];

  # Allow unfree packages (for things like vscode, terraform, etc.)
  nixpkgs.config.allowUnfree = true;
}
```

### 3.2 GUI Apps via Homebrew Casks (`homebrew.nix`)

> Many macOS GUI apps aren't in nixpkgs or have signing/update issues via Nix.
> nix-darwin can manage Homebrew declaratively — installing/uninstalling casks to match config.

```nix
{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";     # Remove anything not declared here
      upgrade = true;
    };

    taps = [
      "nikitabobko/tap"    # AeroSpace
      "FelixKratz/formulae" # SketchyBar, borders
    ];

    brews = [
      "sketchybar"
      "borders"            # JankyBorders (window borders)
    ];

    casks = [
      # Window Management
      "nikitabobko/tap/aerospace"

      # Browsers
      "arc"
      "firefox"

      # Dev Tools
      "visual-studio-code"
      "wezterm"            # or "alacritty", "kitty"
      "docker"
      "orbstack"

      # Productivity
      "raycast"
      "obsidian"
      "1password"
      "1password-cli"

      # Communication
      "slack"
      "microsoft-teams"

      # Media
      "spotify"
      "vlc"

      # Utilities
      "istat-menus"
      "karabiner-elements"
      "the-unarchiver"
      "appcleaner"

      # Add your current casks here
      # Run: brew list --cask
    ];

    masApps = {
      # Mac App Store apps (requires `mas` CLI)
      # "App Name" = APP_ID;
    };
  };
}
```

---

## Phase 4: AeroSpace Configuration

AeroSpace is configured via a TOML file. Home Manager can manage it declaratively:

```nix
# modules/home/aerospace.nix
{ config, ... }: {
  # AeroSpace installed via Homebrew cask (see homebrew.nix)
  # Config managed via Home Manager
  xdg.configFile."aerospace/aerospace.toml".text = ''
    # Start AeroSpace at login
    start-at-login = true

    # Mouse follows focus
    on-focus-changed = ['move-mouse window-lazy-center']

    # Normalizations
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # Gaps
    [gaps]
    inner.horizontal = 10
    inner.vertical   = 10
    outer.left       = 10
    outer.bottom     = 10
    outer.top        = 10
    outer.right      = 10

    # Main mode bindings
    [mode.main.binding]
    alt-enter = 'exec-and-forget open -na WezTerm'

    # Focus
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # Move windows
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # Workspaces
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    # Move window to workspace
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'

    # Layout
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    alt-f     = 'fullscreen'
    alt-shift-f = 'layout floating tiling'

    # Resize
    alt-shift-minus = 'resize smart -50'
    alt-shift-equal = 'resize smart +50'

    # Service mode
    alt-shift-semicolon = 'mode service'

    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r   = ['flatten-workspace-tree', 'mode main']
    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']

    # Workspace-to-monitor assignments (adjust to your setup)
    # [workspace-to-monitor-force-assignment]
    # 1 = 'main'
    # 2 = 'main'
    # 7 = 'secondary'
    # 8 = 'secondary'
    # 9 = 'secondary'
  '';
}
```

---

## Phase 5: SketchyBar Configuration

SketchyBar is highly customizable. The config lives as shell scripts (or Lua). Home Manager manages the config directory:

```nix
# modules/home/sketchybar/default.nix
{ config, pkgs, ... }: {

  # Ensure helper tools are available
  home.packages = with pkgs; [
    jq
    lua5_4  # If using Lua-based config
  ];

  # SketchyBar config directory
  xdg.configFile."sketchybar" = {
    source = ./config;
    recursive = true;
  };

  # Alternative: inline a simpler config
  # xdg.configFile."sketchybar/sketchybarrc".text = ''
  #   ...
  # '';
}
```

Example config structure at `modules/home/sketchybar/config/`:

```
config/
├── sketchybarrc          # Main config (entry point)
├── colors.sh             # Color definitions
├── icons.sh              # Icon mappings (SF Symbols / Nerd Font)
├── plugins/
│   ├── aerospace.sh      # AeroSpace workspace indicator
│   ├── battery.sh
│   ├── clock.sh
│   ├── cpu.sh
│   ├── media.sh
│   ├── volume.sh
│   ├── wifi.sh
│   └── front_app.sh
└── items/
    ├── spaces.sh         # Workspace items (AeroSpace integration)
    ├── front_app.sh
    ├── clock.sh
    ├── battery.sh
    └── media.sh
```

### SketchyBar ↔ AeroSpace Integration

The key integration point: SketchyBar displays AeroSpace workspaces. In your `sketchybarrc`:

```bash
# In sketchybarrc — workspace indicators driven by AeroSpace
for sid in $(aerospace list-workspaces --all); do
  sketchybar --add item space.$sid left \
    --set space.$sid \
      icon="$sid" \
      icon.padding_left=10 \
      icon.padding_right=10 \
      background.color=0x44ffffff \
      background.corner_radius=5 \
      background.height=24 \
      click_script="aerospace workspace $sid" \
      script="$PLUGIN_DIR/aerospace.sh $sid"
done

# Subscribe to AeroSpace workspace change events
sketchybar --add event aerospace_workspace_change
```

In AeroSpace config, notify SketchyBar on workspace changes:

```toml
# Add to aerospace.toml
exec-on-workspace-change = [
  '/bin/bash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
]
```

---

## Phase 6: Shell & Dotfiles (Home Manager)

```nix
# modules/home/shell.nix
{ config, pkgs, ... }: {

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      share = true;
    };
    shellAliases = {
      rebuild = "darwin-rebuild switch --flake ~/.config/nix-darwin";
      ls  = "eza --icons";
      ll  = "eza -la --icons";
      cat = "bat";
      cd  = "z";
      lg  = "lazygit";
      k   = "kubectl";
    };
    initExtra = ''
      # Extra zsh config here
      eval "$(zoxide init zsh)"
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # settings = { ... };  # or use a TOML file
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # Fast nix integration
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Howard";
    userEmail = "<YOUR_EMAIL>";
    delta.enable = true;        # Better diffs
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
  };

  programs.bat = {
    enable = true;
    config.theme = "Catppuccin-mocha";  # Or your preferred theme
  };
}
```

---

## Phase 7: Fonts

```nix
# modules/darwin/fonts.nix
{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      sf-symbols        # Needed for SketchyBar icons
      inter
    ];
  };
}
```

---

## Migration Checklist

### Pre-Migration (Audit Current System)

```bash
# Export current Homebrew state
brew bundle dump --file=~/Brewfile.backup
brew list --formula > ~/brew-formulas.txt
brew list --cask > ~/brew-casks.txt

# Capture current macOS defaults you care about
defaults read > ~/macos-defaults-backup.plist

# List current launch agents/daemons
ls ~/Library/LaunchAgents/
ls /Library/LaunchDaemons/

# Backup dotfiles
cp -r ~/.zshrc ~/.gitconfig ~/.config ~/dotfiles-backup/
```

### Migration Order

| Step | Action | Risk |
|------|--------|------|
| 1 | Install Nix (Determinate) | Low — coexists with Brew |
| 2 | Create flake + basic nix-darwin config | Low |
| 3 | Move CLI tools from Brew → Nix (`packages.nix`) | Low — test each |
| 4 | Set up Home Manager for dotfiles | Low |
| 5 | Move macOS defaults to `system.nix` | Medium — test carefully |
| 6 | Configure AeroSpace via Home Manager | Low |
| 7 | Configure SketchyBar via Home Manager | Medium |
| 8 | Move GUI apps to `homebrew.nix` (declarative Cask) | Low |
| 9 | Uninstall standalone Homebrew packages | Medium |
| 10 | Final cleanup + test fresh rebuild | High — do on a calm day |

### Post-Migration Workflow

```bash
# Edit config
nvim ~/.config/nix-darwin/modules/darwin/system.nix

# Apply changes
darwin-rebuild switch --flake ~/.config/nix-darwin

# Update all inputs (nixpkgs, home-manager, etc.)
nix flake update --flake ~/.config/nix-darwin
darwin-rebuild switch --flake ~/.config/nix-darwin

# Rollback if something breaks
darwin-rebuild switch --flake ~/.config/nix-darwin --rollback

# Search for packages
nix search nixpkgs <package>
```

---

## Key Decisions to Make

| Decision | Options | Recommendation |
|----------|---------|----------------|
| **Terminal emulator** | WezTerm, Alacritty, Kitty, Ghostty | WezTerm or Ghostty — both Nix-configurable |
| **Editor** | Neovim (nix-managed), VS Code (Cask) | Both — Neovim via Home Manager, VS Code via Cask |
| **Shell** | Zsh, Fish, Nushell | Zsh — best macOS compat, most SketchyBar scripts assume it |
| **Prompt** | Starship, Powerlevel10k, Oh-My-Posh | Starship — native Home Manager support |
| **Nix installer** | Official, Determinate Systems | Determinate — better macOS experience |
| **SketchyBar config style** | Shell scripts, Lua | Shell — larger community, more examples |
| **GUI apps** | All Nix, All Cask, Hybrid | Hybrid — CLI via Nix, GUI via declarative Homebrew |
| **Config repo location** | `~/.config/nix-darwin`, `~/.nixos-config` | `~/.config/nix-darwin` — follows XDG convention |

---

## Useful References

- [nix-darwin options search](https://searchnix.com/options/darwin) — searchable list of all nix-darwin options
- [nix-darwin manual](https://daiderd.com/nix-darwin/manual/index.html)
- [Home Manager options](https://nix-community.github.io/home-manager/options.xhtml)
- [SketchyBar docs](https://felixkratz.github.io/SketchyBar/)
- [AeroSpace docs](https://nikitabobko.github.io/AeroSpace/guide)
- [Determinate Nix installer](https://determinate.systems/posts/determinate-nix-installer/)
- [Example dotfiles: FelixKratz](https://github.com/FelixKratz/dotfiles) — SketchyBar creator's setup
- [Example dotfiles: ryan4yin/nix-darwin-kickstarter](https://github.com/ryan4yin/nix-darwin-kickstarter)
