{ ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./terminal.nix
    ./aerospace.nix
    ./karabiner.nix
    ./sketchybar
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
