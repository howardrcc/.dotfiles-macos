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
      cleanup = "sudo nix-collect-garbage --delete-older-than 7d && nix-collect-garbage --delete-older-than 7d && nix store optimise";

      # File listing (eza)
      ls = "eza --icons=always -a";
      ll = "eza --icons=always -l -a --group-directories-first";

      # Better defaults
      cat = "bat";

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

      # Home/End
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[OH" beginning-of-line
      bindkey "^[OF" end-of-line

      # Delete
      bindkey "^[[3~" delete-char

      # Java (Homebrew-managed openjdk)
      export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

      # Pipx / local user bin
      export PATH="$HOME/.local/bin:$PATH"

      # .NET global tools
      export PATH="$HOME/.dotnet/tools:$PATH"

      # Cargo / Rust
      [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

      # NVM
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

      # TinyTeX (R-managed TeX Live; auto-installs missing .sty files).
      # Bootstrap: R -e 'tinytex::install_tinytex()' (or extract the prebuilt
      # tarball to ~/Library/TinyTeX manually). See modules/darwin/r.nix.
      export PATH="$HOME/Library/TinyTeX/bin/universal-darwin:$PATH"
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
    options = [ "--cmd cd" ];   # ← zoxide takes over the cd command
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
