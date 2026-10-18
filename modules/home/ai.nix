{ inputs, ... }:

{
  # Agent skills, pinned by flake.lock. Bump with `nix flake update mattpocock-skills cursor-plugins`.
  # Per-skill links only — sibling skills in these dirs stay unmanaged (plugins, `npx skills`).
  home.file = {
    # Claude Code: unslop (cursor/plugins, pstack)
    ".claude/skills/unslop" = {
      source = "${inputs.cursor-plugins}/pstack/skills/unslop";
      recursive = true;
    };

    # Codex: grilling (mattpocock/skills)
    ".codex/skills/grilling" = {
      source = "${inputs.mattpocock-skills}/skills/productivity/grilling";
      recursive = true;
    };
  };
}
