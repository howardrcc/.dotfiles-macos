{ ... }:

{
  # AeroSpace is installed via Homebrew cask in homebrew.nix.
  # Config is managed declaratively here via Home Manager.
  xdg.configFile."aerospace/aerospace.toml".source =
    ../../archive/config/aerospace/aerospace.toml;
}
