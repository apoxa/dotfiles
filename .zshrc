# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load The Prompt System And Completion System And Initilize Them.
autoload -Uz compinit promptinit

#=== HELPER METHODS ===================================
function error() { print -P "%F{red}[ERROR]%f: %F{yellow}$1%f" && return 1 }
function info() { print -P "%F{blue}[INFO]%f: %F{cyan}$1%f"; }
#=== ZINIT ============================================
typeset -gAH ZINIT;
ZINIT[HOME_DIR]=$HOME/.local/share/zsh/zinit  ZPFX=$ZINIT[HOME_DIR]/polaris
ZINIT[BIN_DIR]=$ZINIT[HOME_DIR]/zinit.git ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1
ZINIT[COMPLETIONS_DIR]=$ZINIT[HOME_DIR]/completions ZINIT[SNIPPETS_DIR]=$ZINIT[HOME_DIR]/snippets
ZINIT[ZCOMPDUMP_PATH]=$ZINIT[HOME_DIR]/zcompdump    ZINIT[PLUGINS_DIR]=$ZINIT[HOME_DIR]/plugins
ZI_REPO='zdharma-continuum'; GH_RAW_URL='https://raw.githubusercontent.com'
if [[ ! -e $ZINIT[BIN_DIR] ]]; then
  info 'downloading zinit' \
  && command mkdir -pv $ZINIT[HOME_DIR] \
  && command git clone \
    https://github.com/$ZI_REPO/zinit.git \
    $ZINIT[BIN_DIR] \
  || error 'failed to clone zinit repository' \
  && info 'setting up zinit' \
  && command chmod g-rwX $ZINIT[HOME_DIR] \
  && zcompile $ZINIT[BIN_DIR]/zinit.zsh \
  && info 'sucessfully installed zinit'
fi
if [[ -e $ZINIT[BIN_DIR]/zinit.zsh ]]; then
  source $ZINIT[BIN_DIR]/zinit.zsh \
    && autoload -Uz _zinit \
    && (( ${+_comps} )) \
    && _comps[zinit]=_zinit
else error "unable to find 'zinit.zsh'" && return 1
fi
#=== STATIC ZSH BINARY =======================================
zi for atpull"%atclone" depth"1" lucid nocompile nocompletions as"null" \
    atclone"./install -e no -d ~/.local" atinit"export PATH=$HOME/.local/bin:$PATH" \
  @romkatv/zsh-bin

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

typeset -g HISTSIZE=290000 SAVEHIST=290000

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

#=== ANNEXES ==========================================
zi light-mode for \
    "${ZI_REPO}"/zinit-annex-{'bin-gem-node','binary-symlink','patch-dl','submods','meta-plugins'}

# #=== OH-MY-ZSH & PREZTO PLUGINS =======================
zi for is-snippet \
  OMZL::{'clipboard','compfix','completion','git','grep','key-bindings'}.zsh \
  PZT::modules/{'history','rsync'}
zi as'completion' for OMZP::{'golang/_golang','pip/_pip','terraform/_terraform'}

#=== COMPLETIONS ======================================
local GH_RAW_URL='https://raw.githubusercontent.com'
install_completion(){ zinit for as'completion' nocompile id-as"$1" is-snippet "$GH_RAW_URL/$2"; }
install_completion 'fd-completion/_fd'         'sharkdp/fd/master/contrib/completion/_fd'

#=== PROMPT ===========================================
zi ice depth=1; zinit light romkatv/powerlevel10k

#=== GITHUB BINARIES ==================================
zi from'gh-r' lbin'!' nocompile for \
    @sharkdp/fd \
    atload='export BAT_THEME="base16-256"; alias cat="bat"' @sharkdp/bat \
    @junegunn/fzf

#=== TRIGGERED ============================================
zi light-mode for \
    trigger-load'!man' ael-code/zsh-colored-man-pages

#=== MISC. ============================================
zi light-mode for \
    apoxa/kubernetes-helpers \
    zsh-users+fast \
        autoload'#manydots-magic' \
    knu/zsh-manydots-magic \
        compile'h*' \
    "${ZI_REPO}"/history-search-multi-word \
        atclone"local P=${${(M)OSTYPE:#*darwin*}:+g}
        \${P}dircolors -b LS_COLORS > c.zsh" \
        atpull'%atclone' pick"c.zsh" nocompile'!' \
        atload'zstyle ":completion:*:default" list-colors "${(s.:.)LS_COLORS}";' \
    trapd00r/LS_COLORS \
    chrissicool/zsh-256color \
        atload'alias gi="git-ignore"' \
    laggardkernel/git-ignore \
    hlissner/zsh-autopair \
    ptavares/zsh-direnv \
    TwoPizza9621536/zsh-plenv \
        atload'abbrev-alias -g G="| grep"; abbrev-alias -g L="| less"' \
    momo-lab/zsh-abbrev-alias \
        atload'export YSU_IGNORED_GLOBAL_ALIASES=("G" "L"); export YSU_MESSAGE_POSITION="after"' \
    MichaelAquilina/zsh-you-should-use \
        if'[[ -n "$ITERM_PROFILE" ]]' pick'shell_integration/zsh' sbin"utilities/*" \
    gnachman/iTerm2-shell-integration \
        atload'(( $+commands[viddy] )) && export ZSH_WATCH=viddy ZSH_WATCH_FLAGS="-t -d -n1 --pty"' \
    Thearas/zsh-watch \
        if"(( ! $+EMACS )) && [[ $TERM != 'dumb' ]] && (( ! $+VIM_TERMINAL ))" \
    jreese/zsh-titles \
    fdellwing/zsh-bat

zi for atload'
      zicompinit; zicdreplay
      _zsh_highlight_bind_widgets
      _zsh_autosuggest_bind_widgets' \
    as'null' id-as'zinit/cleanup' lucid nocd wait \
  $ZI_REPO/null

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
fi

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
    LENGTH=${1-16}
    COUNT=${2-1}
    (( $+commands[pwgen] )) || return 1
    pwgen --capitalize --symbols --numerals --remove-chars="ZzYy\"§%\&/\(\)=?\`´+*#-_\[\]\|\{\}^~<>;@:'" --secure --ambiguous ${LENGTH} ${COUNT}
}
# }}}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
