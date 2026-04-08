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
    jdk21
    # Dev tools
    neovim
    lazygit
    gh
    dotnet-sdk_8 # .NET 8 LTS
    # delta (git diff pager) managed via programs.delta in home/git.nix
    python312
    # Scripting (used by SketchyBar Lua config)
    lua5_4
    luarocks

    # Sync
    syncthing

    # Nix tools
    nil # Nix LSP
    nixfmt # (was nixfmt-rfc-style, now the same package)
    nix-tree

    # macOS media helpers (used by SketchyBar plugins)
    nowplaying-cli
    switchaudio-osx

    #sd card tools
    fio
  ];
}
