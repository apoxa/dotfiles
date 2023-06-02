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
unsetopt CLOBBER            # Do not overwrite existing files with > and >>. Use >! and >>! to bypass.
unsetopt BG_NICE            # Don't run all background jobs at a lower priority.
unsetopt HUP                # Don't kill jobs on shell exit.
unsetopt MAIL_WARNING       # Don't print a warning message if a mail file has been accessed.
unsetopt SHARE_HISTORY

# Provide A Simple Prompt Till The Theme Loads
PS1="READY >"


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

######################
# Trigger-load block #
######################


zt light-mode for \
    trigger-load'!man' \
        ael-code/zsh-colored-man-pages

##################
# Wait'0a' block #
##################

zt 0a light-mode for \
    PZTM::completion/init.zsh \
    as'completion' atpull'zinit cclear' pick'/dev/null' blockf \
        @zsh-users+fast \
        yzdann/kctl \
        apoxa/kubernetes-helpers

##################
# Wait'0b' block #
##################

zt 0b light-mode for \
    autoload'#manydots-magic' \
        knu/zsh-manydots-magic \
    compile'h*' \
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
        ptavares/zsh-direnv \
        TwoPizza9621536/zsh-plenv \
    atload'abbrev-alias -g G="| grep"; abbrev-alias -g L="| less"' \
        momo-lab/zsh-abbrev-alias \
    atload'export YSU_IGNORED_GLOBAL_ALIASES=("G" "L"); export YSU_MESSAGE_POSITION="after"' \
        MichaelAquilina/zsh-you-should-use \
    if'[[ -n "$ITERM_PROFILE" ]]' pick'shell_integration/zsh' sbin"utilities/*" \
        gnachman/iTerm2-shell-integration


# zsh-titles causes dittography in Emacs shell and Vim terminal
zt 1a light-mode if"(( ! $+EMACS )) && [[ $TERM != 'dumb' ]] && (( ! $+VIM_TERMINAL ))" for \
    jreese/zsh-titles \
    fdellwing/zsh-bat

zt 1a light-mode binary from'gh-r' lman lbin'!' for \
    @sharkdp/fd \
    atload='export BAT_THEME="base16-256"; alias cat="bat"' \
        @sharkdp/bat


zt 1a light-mode null for \
    lbin'!' from'gh-r' dl'https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1' lman \
        junegunn/fzf \
    id-as'Cleanup' nocd atinit'unset -f zt' \
        zdharma-continuum/null


# Theme no. 1 – geometry
zinit lucid load'![[ $MYPROMPT = 1 ]]' unload'![[ $MYPROMPT != 1 ]]' \
 atload'!geometry_hostname() {echo ${SSH_TTY:+"%F{9}%n%f%F{7}@%f%F{3}%m%f "}}
        GEOMETRY_STATUS_COLOR="$(geometry::hostcolor)"
        geometry::prompt' \
 atinit'GEOMETRY_PROMPT=(geometry_echo geometry_status geometry_hostname geometry_path)
        GEOMETRY_RPROMPT=(geometry_jobs geometry_exec_time geometry_kube geometry_git geometry_echo)' \
 ver'main' \
 nocd for \
    geometry-zsh/geometry

# Theme no. 2 – pure
zinit lucid load'![[ $MYPROMPT = 2 ]]' unload'![[ $MYPROMPT != 2 ]]' \
 pick"/dev/null" multisrc"{async,pure}.zsh" atload'!prompt_pure_precmd' nocd for \
    sindresorhus/pure

zinit ice depth=1; zinit light romkatv/powerlevel10k

# set prompt
MYPROMPT=3

# }}}

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
(( $+commands[watch] )) && alias watch='watch ' # This allows to watch on aliases
(( $+commands[stern] )) && alias capilogs='stern -n capi-extension-system,capi-kubeadm-bootstrap-system,capi-kubeadm-control-plane-system,capi-system,capvcd-system . '

if (( $+commands[op] )); then
    op-signin() {
        accountname="${1:${OP_DEFAULT_SESSION:-my}}"
        SESSION="OP_SESSION_${accountname}"
        if [[ -z ${(P)SESSION} ]]; then
            eval $(op signin ${accountname})
        fi
    }
    op-signout() {
        accountname="${1:${OP_DEFAULT_SESSION:-my}}"
        SESSION="OP_SESSION_${accountname}"
        op signout --account "${accountname}"
        unset "${SESSION}"
    }
fi

function secpass() {
    LENGTH=${1-16}
    COUNT=${2-1}
    if (( ! $+commands[pwgen] )); then return 1; fi
    pwgen --capitalize --symbols --numerals --remove-chars="ZzYy\"§%\&/\(\)=?\`´+*#-_\[\]\|\{\}^~<>;@:'" --secure --ambiguous ${LENGTH} ${COUNT}
}
# }}}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
