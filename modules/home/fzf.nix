{ ... }:

let
  fdFiles = "fd --type f --hidden --strip-cwd-prefix --exclude .git";
  fdDirs = "fd --type d --hidden --strip-cwd-prefix --exclude .git";
  batPreview = "bat --color=always --style=numbers --line-range=:300 {}";
in
{
  # Usage notes: docs/fzf.md
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    # fd respects .gitignore; fzf's built-in walker doesn't
    defaultCommand = fdFiles;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--bind=ctrl-/:toggle-preview"
    ];

    # Ctrl-T
    fileWidgetCommand = fdFiles;
    fileWidgetOptions = [ "--preview '${batPreview}'" ];

    # Alt-C
    changeDirWidgetCommand = fdDirs;
    changeDirWidgetOptions = [ "--preview 'eza --tree --level=2 --icons=always --color=always {}'" ];
  };

  programs.zsh.initContent = ''
    # ** completion uses fd too
    _fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
    _fzf_compgen_dir()  { fd --type d --hidden --exclude .git . "$1"; }

    # fe [query]: open files in nvim
    fe() {
      local out
      out=$(fzf -m --query "$*" --preview '${batPreview}') || return
      nvim ''${(f)out}
    }

    # fco: switch to a local or remote git branch
    fco() {
      local branch
      branch=$(git for-each-ref --format='%(refname)' refs/heads refs/remotes |
        grep -v '/HEAD$' | sed -E 's#^refs/(heads|remotes)/##' |
        fzf --preview 'git log --oneline --graph --color=always -20 {}') || return
      if git show-ref --verify --quiet "refs/heads/$branch"; then
        git switch "$branch"
      else
        git switch --track "$branch"
      fi
    }

    # flog [git log args]: browse commits, Enter opens the full commit
    flog() {
      git log --oneline --color=always "$@" |
        fzf --ansi --no-sort \
            --preview 'git show --color=always {1}' \
            --bind 'enter:execute(git show {1})'
    }

    # fkill [signal]: kill selected processes (default TERM)
    fkill() {
      local pids
      pids=$(ps -ef | fzf -m --header-lines=1 | awk '{print $2}') || return
      [ -n "$pids" ] && echo "$pids" | xargs kill -"''${1:-TERM}"
    }

    # rgf [query]: live ripgrep, Enter opens the match in nvim
    rgf() {
      local rg="rg --line-number --no-heading --color=always --smart-case"
      : | fzf --ansi --disabled --query "$*" \
          --bind "start:reload:[ -n {q} ] && $rg {q} || true" \
          --bind "change:reload:sleep 0.1; [ -n {q} ] && $rg {q} || true" \
          --delimiter : \
          --preview 'bat --color=always {1} --highlight-line {2}' \
          --preview-window 'right,55%,+{2}/2' \
          --bind 'enter:become(nvim {1} +{2})'
    }
  '';
}
