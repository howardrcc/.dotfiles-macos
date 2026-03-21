{ lib, ... }:

{
  # Karabiner-Elements is installed via Homebrew cask in homebrew.nix.
  # Config seeded from dotfiles on first activation; edit via GUI freely.
  # To persist GUI changes back: cp ~/.config/karabiner/karabiner.json ~/.dotfiles/karabiner/karabiner.json
  home.activation.karabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f ~/.config/karabiner/karabiner.json ]; then
      mkdir -p ~/.config/karabiner
      cp ${../../karabiner/karabiner.json} ~/.config/karabiner/karabiner.json
      chmod 644 ~/.config/karabiner/karabiner.json
    fi
  '';
}
