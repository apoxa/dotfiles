# ~/.config/zsh/comp-cache.zsh — sourced, never executed directly.
# Generic "write completion + diff + conditionally invalidate zcompdump"
# mechanism, used by both mise postinstall hooks (see
# ~/.config/mise/config.toml) and the periodic/manual Group-B refresh in
# ~/.zshrc. The list of Group-B tools (COMP_CACHE_GROUP_B) is maintained in
# ~/.zshrc, not here — this file only provides the mechanism.

: ${ZSH_CACHE_DIR:=$HOME/.cache/zsh}
: ${ZSH_COMPLETIONS_CACHE_DIR:=$ZSH_CACHE_DIR/completions}

# comp-cache-write <name> -- <generator command...>
# Runs the generator; if its stdout differs from the cached _<name> file,
# atomically replaces it and invalidates .zcompdump so the NEXT shell does a
# full compinit and picks it up natively. No-ops (and leaves the old cache
# alone) on a failing or empty generator run.
comp-cache-write() {
    emulate -L zsh
    local name=$1; shift
    [[ $1 == "--" ]] && shift
    local target="$ZSH_COMPLETIONS_CACHE_DIR/_${name}"
    local tmp="${target}.new.$$"
    mkdir -p "$ZSH_COMPLETIONS_CACHE_DIR"

    if ! "$@" >| "$tmp" 2>/dev/null || [[ ! -s "$tmp" ]]; then
        print -u2 "comp-cache: '$*' failed or produced no output; leaving cached completion for '$name' untouched"
        rm -f "$tmp"
        return 1
    fi
    if [[ -f "$target" ]] && cmp -s "$tmp" "$target"; then
        rm -f "$tmp"          # unchanged — nothing to invalidate
        return 0
    fi
    mv -f "$tmp" "$target"
    rm -f "$HOME/.zcompdump" "$HOME/.zcompdump.zwc"
    print -u2 "comp-cache: updated '$name' completion; next new shell will do a full compinit"
}

# Refreshes every tool listed in the global associative array
# COMP_CACHE_GROUP_B (name -> completion-generator command), declared in
# ~/.zshrc. Skips tools that aren't currently installed.
comp-cache-refresh-group-b() {
    emulate -L zsh
    local name cmd
    for name cmd in ${(kv)COMP_CACHE_GROUP_B}; do
        (( $+commands[$name] )) || continue     # e.g. ngrok: not installed yet
        comp-cache-write "$name" -- ${(z)cmd}
    done
}

# Manual convenience entry point — same code path as the periodic check.
comp-cache-refresh() { comp-cache-refresh-group-b "$@" }
