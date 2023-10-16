# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zstyle ':zim:zmodule' use 'degit'
ZIM_HOME=~/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

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

# }}}
#
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

alias l='ls -1A'    # Lists in one column, hidden files
alias ll='ls -lh'   # Lists human readable sizes
alias la='ll -A'    # Lists human readable sizes, hidden files.
alias sl='ls'       # Catch typos.

alias grep="${aliases[grep]:-grep} --color=auto"

# Disable globbing for some commands
alias find='noglob find'
alias history='noglob history'
(( $+commands[rsync] )) && alias rsync='noglob rsync'
alias scp='noglob scp'

# General aliases
alias _='sudo'
alias mkdir="${aliases[mkdir]:-mkdir} -p"
if [[ "$OSTYPE" == darwin* ]]; then
    alias o='open'
    (( $+commands[weechat] )) && alias weechat="OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES weechat"
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

if [[ "$OSTYPE" == (darwin*|*bsd*) ]]; then
  alias topc='top -o cpu'
  alias topm='top -o vsize'
else
  alias topc='top -o %CPU'
  alias topm='top -o %MEM'
fi

(( $+commands[ip] )) && alias ip='ip -c'
(( $+commands[hub] )) && eval "$(hub alias -s)"
(( $+commands[thefuck] )) && eval "$(thefuck --alias)"
(( $+commands[anyenv] )) && eval "$(anyenv init -)"
(( $+commands[stern] )) && alias capilogs='stern -n capi-extension-system,capi-kubeadm-bootstrap-system,capi-kubeadm-control-plane-system,capi-system,capvcd-system . '
(( $+commands[op] )) && eval "$(op completion zsh)" && compdef _op op

function secpass() {
    local LENGTH=${1-16}
    local COUNT=${2-1}
    (( $+commands[pwgen] )) || return 1
    pwgen --capitalize --symbols --numerals --remove-chars="ZzYy\"§/\(\)=?\`´+*#-_\[\]\|\{\}^~<>;@:'" --secure --ambiguous ${LENGTH} ${COUNT}
}
function email() {
    local globalsalt="$(op --account my item get "mailbox.org" --format json | jq -r '.fields[] | select(.label=="blame") | .value')"
    local domain='mail.unpatched.de'
    echo ${1%%.*}-$(echo -n ${1}+${globalsalt} | md5sum | cut -c1-8)@${domain}
}
# }}}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
