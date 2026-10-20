{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # Nerd Fonts available in nixpkgs
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack

    # SketchyBar app icons — pinned via nixpkgs instead of the near-daily Homebrew cask
    sketchybar-app-font
  ];
  # SF Mono, SF Pro, and Meslo Nerd Font are managed via Homebrew casks in homebrew.nix
}
