{ inputs, pkgs, lib, ... }:

{
  imports = [
    ../../modules/darwin/system.nix
    ../../modules/darwin/packages.nix
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/fonts.nix
    ../../modules/darwin/r.nix
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

  # Syncthing auto-start
  launchd.user.agents.syncthing = {
    command = "${pkgs.syncthing}/bin/syncthing serve --no-browser";
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = "/Users/howard/Library/Logs/syncthing.log";
      StandardErrorPath = "/Users/howard/Library/Logs/syncthing-error.log";
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  #launchd.daemons.activate-system.serviceConfig.RunAtLoad = lib.mkForce false;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.howard = import ../../modules/home;
}
