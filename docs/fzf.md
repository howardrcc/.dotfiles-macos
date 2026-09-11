# fzf

How to use fzf in this setup. The config is in `modules/home/fzf.nix`.

After changing that file, run `update`, then open a new Ghostty tab or window. Existing shells keep the old `FZF_*` environment variables.

## Key bindings

| Key | What it does | Preview |
|---|---|---|
| `Ctrl-R` | Search shell history, then put the chosen command on the prompt | none |
| `Ctrl-T` | Pick files and paste their paths at the cursor | file contents (bat) |
| `Alt-C` | Pick a subdirectory and `cd` into it | 2-level tree (eza) |
| `**<Tab>` | Fuzzy completion for the current command | none |

`Ctrl-T`, `Alt-C` and `**<Tab>` all use `fd`, so they include hidden files like `.gitignore` but skip `.git/` and anything gitignored. If you need a gitignored file, run `fd --no-ignore | fzf`.

Some `**<Tab>` examples:

```bash
nvim **<Tab>        # files
cd **<Tab>          # directories
ssh **<Tab>         # hosts from ~/.ssh/config and known_hosts
kill -9 **<Tab>     # processes
export **<Tab>      # environment variables
```

The `**` trigger can go after a partial path, e.g. `nvim modules/**<Tab>`.

## Inside any picker

| Key | Action |
|---|---|
| `Ctrl-/` | Show or hide the preview |
| `Tab` / `Shift-Tab` | Mark or unmark an item (pickers that allow several picks) |
| `Ctrl-J` / `Ctrl-K` or arrows | Move down or up |
| `Enter` | Accept |
| `Esc` / `Ctrl-C` | Cancel |

Every picker opens at 40% height below the prompt, top-down, with a border.

### Search syntax

Matching is fuzzy by default. These prefixes change it:

| Pattern | Meaning |
|---|---|
| `'word` | exact match |
| `^src` | prefix |
| `.nix$` | suffix |
| `!test` | exclude |
| `foo \| bar` | either term |

Separate terms with spaces to AND them together, e.g. `^mod .nix$ !sketchy`.

## Shell functions

`fzf.nix` defines these through `programs.zsh.initContent`.

### `fe [query]`: open files in nvim

```bash
fe              # pick from every file under the current directory
fe shell nix    # start with "shell nix" typed into the search box
```

Mark several files with `Tab` and they all open in nvim. Esc cancels without opening nvim.

### `fco`: switch git branch

Lists local and remote branches, with the last 20 commits of the highlighted branch in the preview.

- Picking a local branch runs `git switch <branch>`.
- Picking a remote branch like `origin/feature` runs `git switch --track origin/feature`, which creates a local `feature` that tracks it. If a local `feature` already exists, git refuses. Pick the local entry instead.

### `flog [git log args]`: browse commits

```bash
flog                    # current branch
flog --all              # every branch
flog -- modules/home    # commits touching a path
flog --author=Howard
```

The preview shows each commit's diff. Enter opens the full commit in delta, and quitting it returns you to the list. Results stay in log order while you type, and don't get re-sorted by match score.

### `fkill [signal]`: kill processes

```bash
fkill           # SIGTERM
fkill 9         # SIGKILL
fkill HUP
```

Search `ps -ef` output by name, user or PID. Mark several with `Tab`. Nothing is killed if you cancel.

### `rgf [query]`: live ripgrep

```bash
rgf                     # empty until you type
rgf programs.fzf        # start with a query
```

Unlike the other pickers, ripgrep does the matching here. Each keystroke reruns `rg` on the query, so the query is a ripgrep regex with smart case, not fzf's fuzzy syntax. The preview shows the file with the matching line highlighted and scrolled into view. Enter opens nvim at that line.

## What the config sets

| Variable | Value |
|---|---|
| `FZF_DEFAULT_COMMAND` | `fd --type f --hidden --strip-cwd-prefix --exclude .git` |
| `FZF_DEFAULT_OPTS` | `--height=40% --layout=reverse --border --bind=ctrl-/:toggle-preview` |
| `FZF_CTRL_T_COMMAND` | same as the default command |
| `FZF_CTRL_T_OPTS` | bat preview |
| `FZF_ALT_C_COMMAND` | `fd --type d --hidden --strip-cwd-prefix --exclude .git` |
| `FZF_ALT_C_OPTS` | eza tree preview |

`_fzf_compgen_path` and `_fzf_compgen_dir` make `**<Tab>` use `fd` as well.

Run `env | grep FZF` to check what a shell actually has.

## Not enabled

- `programs.fzf.colors`: needs a theme picked first. fzf uses the terminal's ANSI colors for now.
- `--style full` (fzf 0.58+): a bordered layout with labeled panes. You can try it with `fzf --style full` before adding it to `defaultOptions`.
- `--tmux 80%`: opens fzf in a tmux popup. Only useful if you use tmux.
