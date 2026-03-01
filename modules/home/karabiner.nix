{ ... }:

{
  # Karabiner-Elements is installed via Homebrew cask in homebrew.nix.
  # Config is managed declaratively here via Home Manager.
  xdg.configFile."karabiner/karabiner.json".source =
    ../../karabiner/karabiner.json;
}
