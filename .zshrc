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

# PLUGINS via Sheldon {{{

# Sheldon manages the zsh plugins (deferred via zsh-defer). Binaries such as fd,
# bat, fzf, atuin and the powerlevel10k theme are installed separately and only
# initialized below when present.
if (( $+commands[sheldon] )); then
    eval "$(sheldon source)"
else
    print -P "%F{160}sheldon missing%f — run 'brew install sheldon' and 'sheldon lock'"
fi

# Plugin configuration (formerly zinit atinit/atload) — as plain exports/guards.
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *"
ZSH_BASH_COMPLETIONS_FALLBACK_PATH=/opt/homebrew/etc/bash_completion.d
ZSH_BASH_COMPLETIONS_FALLBACK_REPLACE_LIST=(wg-quick)
ZVM_INIT_MODE=sourcing
export YSU_MESSAGE_POSITION="after"
(( $+commands[viddy] )) && export ZSH_WATCH=viddy ZSH_WATCH_FLAGS="-t -d -n1 --pty"

# tab-title causes dittography in Emacs shell and Vim terminal; skip it there.
if (( ! $+EMACS )) && [[ $TERM != 'dumb' ]] && (( ! $+VIM_TERMINAL )); then
    export ZSH_TAB_TITLE_ENABLE_FULL_COMMAND=true \
           ZSH_TAB_TITLE_CONCAT_FOLDER_PROCESS=true \
           ZSH_TAB_TITLE_DEFAULT_DISABLE_PREFIX=true
fi

# Bind ^y to autosuggest-accept once the deferred plugin has loaded.
(( $+functions[zsh-defer] )) && zsh-defer bindkey "^y" autosuggest-accept

# Binaries (managed outside this repo) — only initialize when present.
if (( $+commands[bat] )); then export BAT_THEME="base16-256"; alias cat="bat"; fi
(( $+commands[fzf] )) && source <(fzf --zsh)                 # requires fzf >= 0.48
(( $+commands[atuin] )) && source <(atuin init zsh --disable-up-arrow)
(( $+commands[kubectl] )) && (( $+commands[kubecolor] )) && \
    alias kubectl="kubecolor" && compdef kubecolor=kubectl
(( $+commands[zsh-patina] )) && eval "$(zsh-patina activate)"
alias gi="git-ignore"

# Feed $LS_COLORS (exported by the LS_COLORS plugin above) into completion colors.
[[ -n $LS_COLORS ]] && zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# powerlevel10k theme (loaded immediately — NOT deferred, prompt needs it).
() {
  local p10k="$(brew --prefix 2>/dev/null)/share/powerlevel10k/powerlevel10k.zsh-theme"
  [[ -r $p10k ]] && source "$p10k"
}

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

# Loop through all files in the ~/.config/fabric/patterns directory
if [[ -d $HOME/.config/fabric/patterns ]]; then
  FABRIC_ALIAS_PREFIX=f_
  for pattern_file in $HOME/.config/fabric/patterns/*; do
      # Get the base name of the file (i.e., remove the directory path)
      pattern_name="${pattern_file##*/}"
      alias_name="${FABRIC_ALIAS_PREFIX:-}${pattern_name}"

      # Create an alias in the form: alias pattern_name="fabric --pattern pattern_name"
      alias_command="alias $alias_name='fabric-ai --pattern $pattern_name'"

      # Evaluate the alias command to add it to the current shell
      eval "$alias_command"
  done

  yt() {
      if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
          echo "Usage: yt [-t | --timestamps] youtube-link"
          echo "Use the '-t' flag to get the transcript with timestamps."
          return 1
      fi

      transcript_flag="--transcript"
      if [ "$1" = "-t" ] || [ "$1" = "--timestamps" ]; then
          transcript_flag="--transcript-with-timestamps"
          shift
      fi
      local video_link="$1"
      fabric -y "$video_link" $transcript_flag
  }
fi
