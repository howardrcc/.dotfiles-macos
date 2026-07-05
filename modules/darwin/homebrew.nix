{ ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      # brew bundle --cleanup removed in Homebrew 5.2+ — cleanup manually with `brew bundle cleanup --force`
      cleanup = "none";
      upgrade = true;
    };

    taps = [
      "felixkratz/formulae" # sketchybar + borders
      "nikitabobko/tap" # aerospace
      "shaunsingh/sfmono-nerd-font-ligaturized" # font-sf-mono-nerd-font-ligaturized
      "manaflow-ai/cmux"
  ];

    brews = [
      "felixkratz/formulae/sketchybar" # Not in nixpkgs
      "felixkratz/formulae/borders" # JankyBorders window borders — not in nixpkgs
      "lua" # Required by sketchybar launchd service (Nix lua not in launchd PATH)
      "unixodbc" # ODBC headers/libs for the `odbc` R package (~/workspace/dwhr)
    ];


casks = [
      # Window management
      "nikitabobko/tap/aerospace"

      # Terminal
      "ghostty"
      "manaflow-ai/cmux/cmux"

      #misc
      "multimc"
      "temurin@25" # Eclipse Temurin JDK 25 for Minecraft/MultiMC — installs to /Library/Java/JavaVirtualMachines so MultiMC auto-detects it (Nix store path would change per-update and break MultiMC's pinned Java home)
      # Browsers
      "firefox"
      "zen"
      "google-chrome"

      # Editors / Dev
      "t3-code"
      "visual-studio-code"
      "codex"
      "r-app" # CRAN binary R 4.4+ for ~/workspace/dwhr development (CRAN-target package)

      # Productivity
      "raycast"
      "obsidian"
      "bitwarden"
      #"1password"
      #"1password-cli"

      # Communication
      "microsoft-outlook"

      # Media
      "spotify"
      "moonlight" # Game streaming client (GameStream/Sunshine) — v6.1.0

      # Input / System utilities
      "karabiner-elements"

      # Fonts (not available in nixpkgs)
      "font-sf-mono"
      "font-sf-mono-nerd-font-ligaturized"
      "font-sf-pro"
      "sf-symbols"
      "font-meslo-lg-nerd-font"
      "font-sketchybar-app-font"
    ];
  };
}
