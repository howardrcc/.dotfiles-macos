{ pkgs, ... }:

{
  # SketchyBar is installed via Homebrew brew in homebrew.nix.
  # Config (Lua-based) is managed declaratively here.
  home.packages = with pkgs; [
    lua5_4 # Runtime for SketchyBar Lua config
    jq # Used by some SketchyBar plugins
  ];

  xdg.configFile."sketchybar" = {
    source = ./config;
    recursive = true;
  };
}
