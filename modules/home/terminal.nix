{ ... }:

{
  # Ghostty config managed as a plain text file
  # (Ghostty is installed via Homebrew cask in homebrew.nix)
  xdg.configFile."ghostty/config".text = ''
    font-family = MesloLGS Nerd Font Mono
    font-size = 16

    window-padding-x = 10
    window-padding-y = 10

    background-opacity = 0.7
    background-blur-radius = 20

    macos-option-as-alt = both

    # Match alacritty CoolNight color scheme feel
    # theme = catppuccin-mocha
  '';
}
