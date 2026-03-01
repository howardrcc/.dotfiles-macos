{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core CLI
    coreutils
    curl
    wget
    ripgrep
    fd
    eza
    jq
    yq
    tree
    btop
    tmux

    # Dev tools
    neovim
    lazygit
    gh
    # delta (git diff pager) managed via programs.delta in home/git.nix

    # Scripting (used by SketchyBar Lua config)
    lua5_4
    luarocks

    # Nix tools
    nil # Nix LSP
    nixfmt # (was nixfmt-rfc-style, now the same package)
    nix-tree

    # macOS media helpers (used by SketchyBar plugins)
    nowplaying-cli
    switchaudio-osx
  ];
}
