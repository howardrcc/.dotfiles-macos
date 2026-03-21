{ lib, ... }:

{
  # AeroSpace is installed via Homebrew cask in homebrew.nix.
  # Config seeded from dotfiles on first activation; edit freely after.
  # To persist changes back: cp ~/.config/aerospace/aerospace.toml ~/.dotfiles/modules/home/aerospace/aerospace.toml
  home.activation.aerospaceConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f ~/.config/aerospace/aerospace.toml ]; then
      mkdir -p ~/.config/aerospace
      cp ${./aerospace/aerospace.toml} ~/.config/aerospace/aerospace.toml
      chmod 644 ~/.config/aerospace/aerospace.toml
    fi
  '';
}
