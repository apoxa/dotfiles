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

# Provide A Simple Prompt Till The Theme Loads
PS1="READY >"

ZINIT_HOME="${ZINIT_HOME:-${ZPLG_HOME:-${ZDOTDIR:-$HOME}/.zinit}}"
ZINIT_BIN_DIR_NAME="${${ZINIT_BIN_DIR_NAME:-$ZPLG_BIN_DIR_NAME}:-bin}"
### Added by Zinit's installer
if [[ ! -f $ZINIT_HOME/$ZINIT_BIN_DIR_NAME/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p $ZINIT_HOME
    command git clone https://github.com/zdharma/zinit $ZINIT_HOME/$ZINIT_BIN_DIR_NAME && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

module_path+=( "${HOME}/.zinit/bin/zmodules/Src" )
zmodload zdharma/zplugin &>/dev/null

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
unsetopt CLOBBER            # Do not overwrite existing files with > and >>. Use >! and >>! to bypass.
unsetopt BG_NICE            # Don't run all background jobs at a lower priority.
unsetopt HUP                # Don't kill jobs on shell exit.
unsetopt MAIL_WARNING       # Don't print a warning message if a mail file has been accessed.
unsetopt SHARE_HISTORY

#
# annexes
zinit light-mode for \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

# Fast-syntax-highlighting & autosuggestions
zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
    zdharma/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
    PZTM::completion/init.zsh

# lib/git.zsh is loaded mostly to stay in touch with the plugin (for the users)
# and for the themes 2 & 3 (lambda-mod-zsh-theme & lambda-gitster)
zinit wait lucid light-mode for \
    OMZL::git.zsh \
 atload"unalias grv g" \
    OMZP::git/git.plugin.zsh \
    OMZP::extract/extract.plugin.zsh \
 atinit"zstyle :omz:plugins:ssh-agent lifetime 9h" \
    OMZP::ssh-agent/ssh-agent.plugin.zsh \

# emulate ... = ../..
zinit as=null autoload=manydots-magic atload=manydots-magic for \
        knu/zsh-manydots-magic

# Theme no. 1 – geometry
zinit lucid load'![[ $MYPROMPT = 1 ]]' unload'![[ $MYPROMPT != 1 ]]' \
 atload'!geometry_hostname() {echo ${SSH_TTY:+"%F{9}%n%f%F{7}@%f%F{3}%m%f "}}
        GEOMETRY_STATUS_COLOR="$(geometry::hostcolor)"
        geometry::prompt' \
 atinit'GEOMETRY_PROMPT=(geometry_echo geometry_status geometry_hostname geometry_path)
        GEOMETRY_RPROMPT=(geometry_jobs geometry_exec_time geometry_git geometry_echo)' \
 nocd for \
    geometry-zsh/geometry

# Theme no. 2 – pure
zinit lucid load'![[ $MYPROMPT = 2 ]]' unload'![[ $MYPROMPT != 2 ]]' \
 pick"/dev/null" multisrc"{async,pure}.zsh" atload'!prompt_pure_precmd' nocd for \
    sindresorhus/pure

# Theme no. 3 - agkozak-zsh-theme
zinit lucid load'![[ $MYPROMPT = 3 ]]' unload'![[ $MYPROMPT != 3 ]]' \
 atload'!_agkozak_precmd' nocd \
    atinit"AGKOZAK_FORCE_ASYNC_METHOD=subst-async
           AGKOZAK_MULTILINE=0
           AGKOZAK_CUSTOM_SYMBOLS=( '⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' 'S')
           AGKOZAK_LEFT_PROMPT_ONLY=1
           " \
 for \
    agkozak/agkozak-zsh-theme

# Theme no. 4 - git-prompt
zinit lucid load'![[ $MYPROMPT = 4 ]]' unload'![[ $MYPROMPT != 4 ]]' \
 atload'!_zsh_git_prompt_precmd_hook' nocd for \
    woefe/git-prompt.zsh

# On OSX, you might need to install coreutils from homebrew and use the
# g-prefix – gsed, gdircolors
zinit wait"0c" lucid reset \
 atclone"local P=${${(M)OSTYPE:#*darwin*}:+g}
        \${P}sed -i \
        '/DIR/c\DIR 38;5;63;1' LS_COLORS; \
        \${P}dircolors -b LS_COLORS > c.zsh" \
 atpull'%atclone' pick"c.zsh" nocompile'!' \
 atload'zstyle ":completion:*:default" list-colors "${(s.:.)LS_COLORS}";' for \
    trapd00r/LS_COLORS \
    chrissicool/zsh-256color

# zsh-autopair
zinit wait'3' lucid for \
 hlissner/zsh-autopair

# zsh-titles causes dittography in Emacs shell and Vim terminal
zinit wait lucid if"(( ! $+EMACS )) && [[ $TERM != 'dumb' ]] && (( ! $+VIM_TERMINAL ))" \
 for \
    jreese/zsh-titles

# A few wait"1 plugins
zinit wait"1" lucid for \
 atinit'zstyle ":history-search-multi-word" page-size "10"
        zstyle ":history-search-multi-word" highlight-color "fg=yellow,bold,bg=red"
 ' \
    zdharma/history-search-multi-word \
    mdumitru/fancy-ctrl-z

# Gitignore plugin – commands gii and gi
zinit wait"2" lucid trigger-load'!gi;!gii' \
 dl'https://gist.githubusercontent.com/psprint/1f4d0a3cb89d68d3256615f247e2aac9/raw -> templates/Zsh.gitignore' \
 for \
    voronkovich/gitignore.plugin.zsh

# Colored man pages
zinit wait"2" lucid trigger-load'!man' \
    for \
        ael-code/zsh-colored-man-pages

# sharkdp/fd, fzf
zinit wait"2" lucid as"null" from"gh-r" for \
    mv"fd* -> fd" sbin"fd/fd"  @sharkdp/fd \
    sbin junegunn/fzf-bin

# set prompt
MYPROMPT=1

# Load perl5 local::lib
[[ -d ~/perl5/lib/perl5 ]] && eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

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
(( $+commands[plenv] )) && eval "$(plenv init - zsh)"
