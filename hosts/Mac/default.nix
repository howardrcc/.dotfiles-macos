{ inputs, pkgs, ... }:

{
  imports = [
    ../../modules/darwin/system.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/fonts.nix
    inputs.home-manager.darwinModules.home-manager
  ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 6;

  # Required: Determinate Systems manages the Nix daemon
  nix.enable = false;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.howard.home = "/Users/howard";
  system.primaryUser = "howard";
  networking.hostName = "Mac";

  security.pam.services.sudo_local.touchIdAuth = true;
  launchd.daemons.activate-system.serviceConfig.RunAtLoad = false;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.howard = import ../../modules/home;
}
