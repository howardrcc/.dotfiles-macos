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

    # Agent skills (plain repos, not flakes) — linked by modules/home/ai.nix
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    cursor-plugins = {
      url = "github:cursor/plugins";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."Mac" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/Mac/default.nix ];
    };
  };
}
