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
    };

    taps = [
      "felixkratz/formulae" # sketchybar + borders
      "nikitabobko/tap" # aerospace
      "shaunsingh/sfmono-nerd-font-ligaturized" # font-sf-mono-nerd-font-ligaturized
    ];

    brews = [
      "felixkratz/formulae/sketchybar" # Not in nixpkgs
      "felixkratz/formulae/borders" # JankyBorders window borders — not in nixpkgs
      "lua" # Required by sketchybar launchd service (Nix lua not in launchd PATH)
    ];

    casks = [
      # Window management
      "nikitabobko/tap/aerospace"

      # Terminal
      "ghostty"

      # Browsers
      "firefox"
      "zen-browser"

      # Editors / Dev
      "visual-studio-code"

      # Productivity
      "raycast"
      "obsidian"
      "1password"
      "1password-cli"

      # Communication
      "microsoft-outlook"

      # Media
      "spotify"

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
