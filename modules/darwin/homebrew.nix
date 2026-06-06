{ ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      # "uninstall" removes packages no longer listed (safer than "zap" during migration)
      # Change to "zap" once the cask list is complete and audited
      cleanup = "uninstall";
      upgrade = true;
      # Homebrew 5.1.15+ requires an explicit force flag to run `brew bundle --cleanup`
      extraFlags = [ "--force" ];
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
      # Browsers
      "firefox"
      "zen"
      "google-chrome"

      # Editors / Dev
      "visual-studio-code"
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
