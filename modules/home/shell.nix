{ config, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "${config.home.homeDirectory}/.zhistory";
      size = 50000;
      save = 50000;
      ignoreDups = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    shellAliases = {
      # Nix rebuild
      update = "sudo darwin-rebuild switch --flake ~/.dotfiles";

      # File listing (eza)
      ls = "eza --icons=always -a";
      ll = "eza --icons=always -l -a";

      # Better defaults
      cat = "bat";
      cd = "z"; # zoxide

      # Dev shortcuts
      lg = "lazygit";
      k = "kubectl";

      # App launchers
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      zed = "open -a /Applications/Zed.app -n";
    };

    initContent = ''
      # Arrow-key history prefix search
      bindkey "^[[A" history-search-backward
      bindkey "^[[B" history-search-forward

      # Java (Homebrew-managed openjdk)
      export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

      # Pipx / local user bin
      export PATH="$HOME/.local/bin:$PATH"

      # Cargo / Rust
      [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

      # NVM
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bat = {
    enable = true;
  };
}
