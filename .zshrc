# Load The Prompt System And Completion System And Initilize Them.
autoload -Uz compinit promptinit

# Load And Initialize The Completion System Ignoring Insecure Directories With A
# Cache Time Of 20 Hours, So It Should Almost Always Regenerate The First Time A
# Shell Is Opened Each Day.
# See: https://gist.github.com/ctechols/ca1035271ad134841284
_comp_files=(${ZDOTDIR:-$HOME}/.zcompdump(Nm-20))
if (( $#_comp_files )); then
    compinit -i -C
else
    compinit -i
fi
unset _comp_files

typeset -g HISTSIZE=290000 SAVEHIST=290000 HISTFILE=~/.zhistory

#
# setopts
#
setopt COMBINING_CHARS      # Combine zero-length punctuation characters (accents) with the base character.
setopt INTERACTIVE_COMMENTS # Enable comments in interactive shell.
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
setopt LONG_LIST_JOBS       # List jobs in the long format by default.
setopt AUTO_RESUME          # Attempt to resume existing job before creating a new process.
setopt NOTIFY               # Report status of background jobs immediately.
setopt CHECK_JOBS           # Report on jobs when shell exit.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
setopt AUTO_CD              # Auto changes to a directory without typing cd.
setopt DOTGLOB              # Match hidden files
setopt HIST_IGNORE_SPACE    # Don't write commands to history if they start with a space
setopt HIST_EXPIRE_DUPS_FIRST    # First delete dups in the history if it needs to be trimmed.
setopt HIST_IGNORE_DUPS     # Do not enter command lines into the history list if they are duplicates of the previous event
setopt HIST_IGNORE_ALL_DUPS # Remove older dups if a new command line is added.
setopt HIST_FIND_NO_DUPS    # Don't display dups when searching in history.
setopt HIST_SAVE_NO_DUPS    # When writing history, older commands which are dups are omitted.
unsetopt CLOBBER            # Do not overwrite existing files with > and >>. Use >! and >>! to bypass.
unsetopt BG_NICE            # Don't run all background jobs at a lower priority.
unsetopt HUP                # Don't kill jobs on shell exit.
unsetopt MAIL_WARNING       # Don't print a warning message if a mail file has been accessed.
unsetopt SHARE_HISTORY

# disable the r builtin command. It's the same as `fc -e -` and conflicts with the R interpreter
disable r

# PLUGINS via Sheldon {{{

# Sheldon manages the zsh plugins (deferred via zsh-defer). Per-plugin config
# (env vars, keybindings) lives next to each plugin as hooks in
# ~/.config/sheldon/plugins.toml. Binaries (fd, bat, fzf, atuin, starship) are
# installed separately and only initialized below when present.
if (( $+commands[sheldon] )); then
    eval "$(sheldon source)"
else
    print -P "%F{160}sheldon missing%f — run 'brew install sheldon' and 'sheldon lock'"
fi

(( $+commands[vivid] )) && export LS_COLORS="$(vivid generate catppuccin-latte)"
[[ -n $LS_COLORS ]] && zstyle ":completion:*:default" list-colors "${(s.:.)LS_COLORS}"

# Binaries (managed outside this repo) — only initialize when present.
# NOTE: atuin (^R) and fzf are initialized in zsh-vi-mode's zvm_after_init hook
# (see ~/.config/sheldon/plugins.toml) so their keybindings survive vi-mode init.
if (( $+commands[bat] )); then export BAT_THEME="base16-256"; alias cat="bat"; fi
(( $+commands[kubectl] )) && (( $+commands[kubecolor] )) && \
    alias kubectl="kubecolor" && compdef kubecolor=kubectl
(( $+commands[zsh-patina] )) && eval "$(zsh-patina activate)"

# starship prompt (loaded immediately — NOT deferred, prompt needs it).
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"

    ## transient prompt setup
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd transient-prompt-precmd

    TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"
    TRANSIENT_RPROMPT="${PROMPT// prompt / prompt --profile rtransient }"

    function transient-prompt-precmd {
        # Fix ctrl+c behavior
        TRAPINT() { transient-prompt; return $(( 128 + $1 )) }

        # Save transient prompt
        SAVED_PROMPT="$(eval "printf '%s' \"${TRANSIENT_PROMPT}\"")"
        SAVED_RPROMPT="$(eval "printf '%s' \"${TRANSIENT_RPROMPT}\"")"
    }

    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget zle-line-finish transient-prompt

    function transient-prompt() {
        # Use saved transient prompt
        # TRAPINT fires on Ctrl+C during a running command ZLE is not active, so
        # bail out to avoid "widgets can only be called when ZLE is active".
        zle || return
        PROMPT="$SAVED_PROMPT" RPROMPT="$SAVED_RPROMPT" zle .reset-prompt
    }

fi

# }}}
#
# Set SSH_AUTH_SOCK to 1password agent, if it exists (may be a symlink)
function () {
    local OP_SSH_SOCK="${HOME}/.1password/agent.sock"
    [[ -n $OP_SSH_SOCK(#qN@^-@) ]] && export SSH_AUTH_SOCK="${OP_SSH_SOCK}"
}

# ALIASES {{{
# ------------------------------
if (( $+commands[ag] )); then
    alias ag='ag --pager less'
    export FZF_DEFAULT_COMMAND='ag -l -g ""'
    export FZF_DEFAULT_OPTS='--no-extended'
fi

if (( $+commands[dircolors] )); then
    alias ls="${aliases[ls]:-ls} --color=auto"
else
    alias ls="${aliases[ls]:-ls} -G"
fi
(( $+commands[gls] )) && alias ls='gls --color'

alias ll='ls -lh'   # Lists human readable sizes
alias la='ll -A'    # Lists human readable sizes, hidden files.
alias sl='ls'       # Catch typos.

alias grep="${aliases[grep]:-grep} --color=auto"

# Disable globbing for some commands
alias find='noglob find'
alias history='noglob history'
(( $+commands[rsync] )) && alias rsync='noglob rsync'

# General aliases
alias _='sudo'
alias mkdir="${aliases[mkdir]:-mkdir} -p"
if [[ "$OSTYPE" == darwin* ]]; then
    alias o='open'
else
    alias o='xdg-open'
    if (( $+commands[xclip] )); then
        alias pbcopy='xclip -selection clipboard -in'
        alias pbpaste='xclip -selection clipboard -out'
    elif (( $+commands[xsel] )); then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    fi
fi

alias pbc='pbcopy'
alias pbp='pbpaste'

# Make aliases work in xargs
alias xargs='xargs '

if [[ "$OSTYPE" == (darwin*|*bsd*) ]]; then
  alias topc='top -o cpu'
  alias topm='top -o vsize'
else
  alias topc='top -o %CPU'
  alias topm='top -o %MEM'
fi

(( $+commands[ip] )) && alias ip='ip -c'
(( $+commands[hub] )) && eval "$(hub alias -s)"
(( $+commands[stern] )) && alias capilogs='stern -n capi-extension-system,capi-kubeadm-bootstrap-system,capi-kubeadm-control-plane-system,capi-system,capvcd-system . '
[[ -o interactive && -t 1 ]] && (( $+commands[op] )) && eval "$(op completion zsh)" && compdef _op op # only on interactive shells, this fixes a popup in claude desktop
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[ngrok] )) && eval "$(ngrok completion)"
(( $+commands[nvim] )) && alias vi='nvim' && alias vim='nvim' && alias vimdiff='nvim -d'
(( $+commands[openstack] )) && alias os='openstack'

function secpass() {
    local LENGTH=${1-16}
    local COUNT=${2-1}
    (( $+commands[pwgen] )) || return 1
    pwgen --capitalize --symbols --numerals --remove-chars="ZzYy\"§&*/\(\)=?\`´+*#-_\[\]\|\{\}^~<>;@:'" --secure --ambiguous ${LENGTH} ${COUNT}
}

function fastrm() {
    (( $+commands[rsync] )) || { echo "rsync is not installed, exiting..."; return 1 }
    local emptydir="$(mktemp -d)"
    rsync -va --delete "${emptydir}/" "${1}/"
    rmdir "${1}"
}
# }}}

[[ -f ~/.config/op/plugins.sh ]] && source ~/.config/op/plugins.sh
