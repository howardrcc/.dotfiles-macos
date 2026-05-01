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

    # Document conversion (R Markdown / R CMD check vignette builds)
    pandoc

    # Sync
    syncthing

    # Nix tools
    nil # Nix LSP
    nixfmt # (was nixfmt-rfc-style, now the same package)
    nix-tree

    # macOS media helpers (used by SketchyBar plugins)
    nowplaying-cli
    switchaudio-osx

    # Container runtime — Colima is a lightweight Docker daemon for macOS
    # that doesn't need Docker Desktop. Bundle the docker CLI + buildx +
    # compose plugins so `docker` / `docker compose` / `docker buildx` work
    # against Colima's socket out of the box.
    # Start once per session: `colima start --cpu 4 --memory 8 --arch aarch64`
    # See ~/workspace/dwhr/docs/DOCKER.md for usage.
    colima
    docker-client
    docker-buildx
    docker-compose

    #sd card tools
#    fio
  ];
}
