# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# PLUGINS {{{

### Added by Zinit's installer
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f "${ZINIT_HOME}/zinit.zsh" ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$(dirname ${ZINIT_HOME})" && command chmod g-rwX "$(dirname ${ZINIT_HOME})"
    command git clone https://github.com/zdharma-continuum/zinit "${ZINIT_HOME}" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-{'as-monitor','bin-gem-node','patch-dl','rust','meta-plugins'}

### End of Zinit's installer chunk

# Functions to make configuration less verbose
# zt() : First argument is a wait time and suffix, ie "0a". Anything that doesn't match will be passed as if it were an ice mod. Default ices depth'3' and lucid
zt(){ zinit depth'3' lucid ${1/#[0-9][a-c]/wait"${1}"} "${@:2}"; }

#
# annexes
zt light-mode for \
    NICHOLAS85/z-a-{'linkman','linkbin'}

##################
# Wait'0a' block #
##################
zt 0a light-mode for \
    PZTM::completion/init.zsh \
    atload'_zsh_autosuggest_start;' zsh-users/zsh-autosuggestions \
    atinit'ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay;' atload'export ZSH_AUTOSUGGEST_MANUAL_REBIND=1; export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20; export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"; bindkey "^y" autosuggest-accept' \
        zsh-users/zsh-autosuggestions \
    atinit'ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay;' \
        zdharma-continuum/fast-syntax-highlighting \
    atinit'ZSH_BASH_COMPLETIONS_FALLBACK_PATH=/opt/homebrew/etc/bash_completion.d; ZSH_BASH_COMPLETIONS_FALLBACK_REPLACE_LIST=(wg-quick)'  \
        3v1n0/zsh-bash-completions-fallback \
    as'completion' is-snippet https://github.com/go-task/task/blob/main/completion/zsh/_task

##################
# Wait'0b' block #
##################

zt 0b light-mode for \
    atinit'ZVM_INIT_MODE=sourcing' atload'ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLOCK' \
        jeffreytse/zsh-vi-mode \
    atload'(( $+commands[kubectl] && $+commands[kubecolor] )) && alias kubectl="kubecolor" && compdef kubecolor=kubectl' \
        yzdann/kctl \
    if"(( ! $+commands[atuin] ))" compile'h*' \
        zdharma-continuum/history-search-multi-word \
    atinit'zicdreplay' atclone'(){local f;cd -q →*;for f (*~*.zwc){zcompile -Uz -- ${f}};}' \
    compile'.*fast*~*.zwc' nocompletions atpull'%atclone' \
        zdharma-continuum/fast-syntax-highlighting

##################
# Wait'0c' block #
##################

# On OSX, you might need to install coreutils from homebrew and use the
# g-prefix – gsed, gdircolors
zt 0c light-mode for \
    atclone"local P=${${(M)OSTYPE:#*darwin*}:+g}
        \${P}dircolors -b LS_COLORS > c.zsh" \
    atpull'%atclone' pick"c.zsh" nocompile'!' \
    atload'zstyle ":completion:*:default" list-colors "${(s.:.)LS_COLORS}";' \
        trapd00r/LS_COLORS \
        chrissicool/zsh-256color

zt 0c light-mode binary for \
    lbin'!' atload'alias gi="git-ignore"' \
        laggardkernel/git-ignore

##################
# Wait'1a' block #
##################
#
zt 1a light-mode for \
        hlissner/zsh-autopair \
    if"(( $+commands[mise] ))" \
        wintermi/zsh-mise \
    atload'export YSU_MESSAGE_POSITION="after"' \
        MichaelAquilina/zsh-you-should-use \
    atload'(( $+commands[viddy] )) && export ZSH_WATCH=viddy ZSH_WATCH_FLAGS="-t -d -n1 --pty"' \
        Thearas/zsh-watch

# zsh-titles causes dittography in Emacs shell and Vim terminal
zt 1a light-mode if"(( ! $+EMACS )) && [[ $TERM != 'dumb' ]] && (( ! $+VIM_TERMINAL ))" for \
    atload'export ZSH_TAB_TITLE_ENABLE_FULL_COMMAND=true ZSH_TAB_TITLE_CONCAT_FOLDER_PROCESS=true ZSH_TAB_TITLE_DEFAULT_DISABLE_PREFIX=true' \
        trystan2k/zsh-tab-title \
    fdellwing/zsh-bat

zt 1a light-mode binary from'gh-r' lman lbin'!' for \
    @sharkdp/fd \
    atload='export BAT_THEME="base16-256"; alias cat="bat"' \
        @sharkdp/bat

zt 1a light-mode null for \
    lbin'!' from'gh-r' dl'https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1' lman \
        junegunn/fzf \
    id-as'atuin' has"atuin" \
        atload'source <(atuin init zsh --disable-up-arrow)' \
        zdharma-continuum/null \
    id-as'Cleanup' nocd atinit'unset -f zt' \
        zdharma-continuum/null

zinit ice depth'1'; zinit light romkatv/powerlevel10k

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
(( $+commands[op] )) && eval "$(op completion zsh)" && compdef _op op
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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/.config/op/plugins.sh ]] || source ~/.config/op/plugins.sh
if [ -f "$HOME/.config/fabric/fabric-bootstrap.inc" ]; then . "$HOME/.config/fabric/fabric-bootstrap.inc"; fi
