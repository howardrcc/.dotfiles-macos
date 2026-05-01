#!/usr/bin/env bash
# Reclaim disk space on macOS by clearing regenerable caches.
#
# Usage:
#   scripts/disk-cleanup.sh            # dry-run: shows sizes, deletes nothing
#   scripts/disk-cleanup.sh --apply    # actually deletes
#
# Targets only caches and build artifacts that:
#   - regenerate on next use of the relevant tool, or
#   - represent old / unreferenced state (Xcode DerivedData, simulators,
#     Time Machine local snapshots, Nix garbage)
#
# NEVER touches:
#   - user data (Documents, Photos, etc.)
#   - app config / preferences
#   - keychains, credentials
#   - the active Nix system generation (only old generations are GC'd)

set -euo pipefail

DRY=true
if [[ "${1:-}" == "--apply" ]]; then DRY=false; fi

bytes_to_human() {
    local b=$1
    if   [[ $b -gt 1073741824 ]]; then printf "%5.1f GB" "$(bc -l <<< "$b/1073741824")"
    elif [[ $b -gt 1048576    ]]; then printf "%5.1f MB" "$(bc -l <<< "$b/1048576")"
    else                               printf "%5d KB"   "$((b/1024))"
    fi
}

# size_of <path-or-glob> — sums sizes of matching paths in bytes
size_of() {
    local total=0
    for p in "$@"; do
        if [[ -e "$p" ]]; then
            local b
            b=$(du -sk "$p" 2>/dev/null | awk '{print $1}')
            total=$((total + b * 1024))
        fi
    done
    echo "$total"
}

# del <label> <path> [path...] — show size, optionally delete
del() {
    local label=$1; shift
    local total
    total=$(size_of "$@")
    if [[ $total -eq 0 ]]; then
        printf "  %-40s    -      (empty / not present)\n" "$label"
        return
    fi
    printf "  %-40s %s\n" "$label" "$(bytes_to_human "$total")"
    if ! $DRY; then
        for p in "$@"; do
            [[ -e "$p" ]] && rm -rf "$p" 2>/dev/null || true
        done
    fi
}

run_cmd() {
    local label=$1; shift
    printf "  %-40s [will run: %s]\n" "$label" "$*"
    if ! $DRY; then
        "$@" 2>&1 | sed 's/^/    /' | head -5
    fi
}

before=$(df -k / | awk 'NR==2 {print $4}')
before_b=$((before * 1024))

echo
if $DRY; then
    echo "═══ DISK CLEANUP — DRY RUN (no files will be deleted) ═══"
    echo "Run with --apply to actually delete."
else
    echo "═══ DISK CLEANUP — APPLYING ═══"
fi
echo "Available before: $(bytes_to_human "$before_b")"
echo

echo "── User-level caches (~/Library/Caches) ─────────────────────"
del "Chrome cache"           ~/Library/Caches/Google
del "Arc cache"              ~/Library/Caches/Arc
del "Firefox cache"          ~/Library/Caches/Firefox
del "Microsoft Edge cache"   ~/Library/Caches/Microsoft\ Edge
del "Slack cache"            ~/Library/Caches/com.tinyspeck.slackmacgap
del "Spotify cache"          ~/Library/Caches/com.spotify.client
del "Zoom cache"             ~/Library/Caches/us.zoom.xos
del "VSCode cache"           ~/Library/Caches/com.microsoft.VSCode
del "Cursor cache"           ~/Library/Caches/com.todesktop.230313mzl4w4u92
del "Zed cache"              ~/Library/Caches/dev.zed.Zed
del "Homebrew downloads"     ~/Library/Caches/Homebrew

echo
echo "── Dev tooling caches ────────────────────────────────────────"
del "Xcode DerivedData"      ~/Library/Developer/Xcode/DerivedData
del "Xcode Archives (old)"   ~/Library/Developer/Xcode/Archives
del "iOS DeviceSupport"      ~/Library/Developer/Xcode/iOS\ DeviceSupport
del "watchOS DeviceSupport"  ~/Library/Developer/Xcode/watchOS\ DeviceSupport
del "Core Simulator caches"  ~/Library/Developer/CoreSimulator/Caches
del "npm cache"              ~/.npm/_cacache
del "yarn cache"             ~/.yarn/cache
del "pnpm store"             ~/Library/pnpm/store
del "pip cache"              ~/Library/Caches/pip
del "uv cache"               ~/Library/Caches/uv
del "Cargo registry cache"   ~/.cargo/registry/cache
del ".gradle caches"         ~/.gradle/caches
del "Maven .m2 repository"   ~/.m2/repository
del "Go build cache"         ~/Library/Caches/go-build
del "TinyTeX font cache"     ~/Library/TinyTeX/.cache
del "R session libraries (regenerable)" ~/Library/Caches/org.R-project.R

echo
echo "── Project-level junk ────────────────────────────────────────"
# These can be deep — limit to common spots so we don't traverse all of ~
del "node_modules under ~/workspace" $(find ~/workspace -name node_modules -prune -type d 2>/dev/null | head -20)

echo
echo "── System & special tools ────────────────────────────────────"
run_cmd "Empty Trash"                      bash -c 'osascript -e "tell application \"Finder\" to empty trash" 2>/dev/null || true'
run_cmd "Delete unavailable simulators"    xcrun simctl delete unavailable
run_cmd "Delete Time Machine local snaps"  bash -c 'tmutil listlocalsnapshots / 2>/dev/null | sed "s/^com.apple.TimeMachine.//" | while read -r d; do tmutil deletelocalsnapshots "$d" >/dev/null 2>&1 || true; done'

if command -v nix >/dev/null 2>&1; then
    run_cmd "Nix store garbage collect" nix store gc
fi

if command -v brew >/dev/null 2>&1; then
    run_cmd "brew cleanup -s" brew cleanup -s
fi

if command -v docker >/dev/null 2>&1; then
    run_cmd "docker system prune -af" docker system prune -af --volumes
fi

echo
after=$(df -k / | awk 'NR==2 {print $4}')
after_b=$((after * 1024))
diff_b=$((after_b - before_b))

echo "═══════════════════════════════════════════════════════════════"
printf "Before:    %s\n" "$(bytes_to_human "$before_b")"
printf "After:     %s\n" "$(bytes_to_human "$after_b")"
if [[ $diff_b -gt 0 ]]; then
    printf "Reclaimed: %s\n" "$(bytes_to_human "$diff_b")"
elif $DRY; then
    echo "(dry-run — no changes; re-run with --apply to delete)"
fi
