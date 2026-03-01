{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # Nerd Fonts available in nixpkgs
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
  ];
  # SF Mono, SF Pro, Meslo Nerd Font, and sketchybar-app-font
  # are managed via Homebrew casks in homebrew.nix
}
