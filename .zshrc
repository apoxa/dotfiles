ZINIT_HOME="${ZINIT_HOME:-${ZPLG_HOME:-${ZDOTDIR:-$HOME}/.zinit}}"
ZINIT_BIN_DIR_NAME="${${ZINIT_BIN_DIR_NAME:-$ZPLG_BIN_DIR_NAME}:-bin}"
### Added by Zinit's installer
if [[ ! -f $ZINIT_HOME/$ZINIT_BIN_DIR_NAME/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p $ZINIT_HOME
    command git clone https://github.com/zdharma/zinit $ZINIT_HOME/$ZINIT_BIN_DIR_NAME && \\
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \\
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$ZINIT_HOME/$ZINIT_BIN_DIR_NAME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

typeset -ga mylogs
zflai-msg() { mylogs+=( "$1" ); }
zflai-assert() { mylogs+=( "$4"${${${1:#$2}:+FAIL}:-OK}": $3" ); }

module_path+=( "${HOME}/.zinit/bin/zmodules/Src" )
zmodload zdharma/zplugin &>/dev/null

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
 atload"!_zsh_autosuggest_start" atinit"ZSH_AUTOSUGGEST_USE_ASYNC=1"\
    zsh-users/zsh-autosuggestions \
 blockf \
    zsh-users/zsh-completions

# lib/git.zsh is loaded mostly to stay in touch with the plugin (for the users)
# and for the themes 2 & 3 (lambda-mod-zsh-theme & lambda-gitster)
zinit wait lucid for \
    zdharma/zsh-unique-id \
    OMZ::lib/git.zsh \
 atload"unalias grv g" \
    OMZ::plugins/git/git.plugin.zsh

# Theme no. 1 - zprompts
zinit lucid \
 load'![[ $MYPROMPT = 1 ]]' \
 unload'![[ $MYPROMPT != 1 ]]' \
 atload'!promptinit; typeset -g PSSHORT=0; prompt sprint3 yellow red green blue' \
 nocd for \
    psprint/zprompts

# Theme no. 2 – lambda-mod-zsh-theme
zinit lucid load'![[ $MYPROMPT = 2 ]]' unload'![[ $MYPROMPT != 2 ]]' nocd for \
    halfo/lambda-mod-zsh-theme

# Theme no. 3 – lambda-gitster
zinit lucid load'![[ $MYPROMPT = 3 ]]' unload'![[ $MYPROMPT != 3 ]]' nocd for \
    ergenekonyigit/lambda-gitster

# Theme no. 4 – geometry
zinit lucid load'![[ $MYPROMPT = 4 ]]' unload'![[ $MYPROMPT != 4 ]]' \
 atload'!geometry::prompt' nocd \
 atinit'GEOMETRY_COLOR_DIR=63 GEOMETRY_PATH_COLOR=63' for \
    geometry-zsh/geometry

# Theme no. 5 – pure
zinit lucid load'![[ $MYPROMPT = 5 ]]' unload'![[ $MYPROMPT != 5 ]]' \
 pick"/dev/null" multisrc"{async,pure}.zsh" atload'!prompt_pure_precmd' nocd for \
    sindresorhus/pure

# Theme no. 6 - agkozak-zsh-theme
zinit lucid load'![[ $MYPROMPT = 6 ]]' unload'![[ $MYPROMPT != 6 ]]' \
 atload'!_agkozak_precmd' nocd \
    atinit"AGKOZAK_FORCE_ASYNC_METHOD=subst-async\
           AGKOZAK_MULTILINE=0
           AGKOZAK_CUSTOM_SYMBOLS=( '⇣⇡' '⇣' '⇡' '+' 'x' '!' '>' '?' 'S')
           AGKOZAK_LEFT_PROMPT_ONLY=1
           " \
 for \
    agkozak/agkozak-zsh-theme

# Theme no. 7 - zinc
zinit load'![[ $MYPROMPT = 7 ]]' unload'![[ $MYPROMPT != 7 ]]' \
 compile"{zinc_functions/*,segments/*,zinc.zsh}" nocompletions \
 atload'!prompt_zinc_setup; prompt_zinc_precmd' nocd for \
    robobenklein/zinc

# Theme no. 8 - powerlevel10k
zinit load'![[ $MYPROMPT = 8 ]]' unload'![[ $MYPROMPT != 8 ]]' \
 atload'!source ~/.p10k.zsh; _p9k_precmd' lucid nocd for \
    romkatv/powerlevel10k

# Theme no. 9 - git-prompt
zinit lucid load'![[ $MYPROMPT = 9 ]]' unload'![[ $MYPROMPT != 9 ]]' \
 atload'!_zsh_git_prompt_precmd_hook' nocd for \
    woefe/git-prompt.zsh

# zunit, color
zinit wait"2" lucid as"null" for \
 sbin atclone"./build.zsh" atpull"%atclone" \
    molovo/zunit \
 sbin"color.zsh -> color" \
    molovo/color

# base16 colorscheme
zinit lucid atinit"BASE16_SHELL_HOOKS=$HOME/.config/base16/hooks" for \
    chriskempson/base16-shell \
    chrissicool/zsh-256color

# On OSX, you might need to install coreutils from homebrew and use the
# g-prefix – gsed, gdircolors
zinit wait"0c" lucid reset \
 atclone"local P=${${(M)OSTYPE:#*darwin*}:+g}
        \${P}sed -i \
        '/DIR/c\DIR 38;5;63;1' LS_COLORS; \
        \${P}dircolors -b LS_COLORS > c.zsh" \
 atpull'%atclone' pick"c.zsh" nocompile'!' \
 atload'zstyle ":completion:*:default" list-colors "${(s.:.)LS_COLORS}";' for \
    trapd00r/LS_COLORS

# fzy
zinit wait"1" lucid as"program" pick"$ZPFX/bin/fzy*" \
 atclone"cp contrib/fzy-* $ZPFX/bin/" \
 make"!PREFIX=$ZPFX install" for \
    jhawthorn/fzy

# zsh-autopair
zinit wait lucid for \
 hlissner/zsh-autopair

# zsh-titles causes dittography in Emacs shell and Vim terminal
zinit wait lucid if"(( ! $+EMACS )) && [[ $TERM != 'dumb' ]] && (( ! $+VIM_TERMINAL ))" \
 for \
    jreese/zsh-titles

# A few wait"1 plugins
zinit wait"1" lucid for \
 atinit'zstyle ":history-search-multi-word" page-size "7"' \
    zdharma/history-search-multi-word

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

# A few wait'2' plugins
zinit wait"2" lucid for \
    zdharma/declare-zsh \
    zdharma/zflai \
 blockf \
    zdharma/zui \
    zinit-zsh/zinit-console \
 trigger-load'!crasis' \
    zdharma/zplugin-crasis \
 atinit"forgit_ignore='fgi'" \
    wfxr/forgit

# A few wait'3' git extensions
zinit as"null" wait"3" lucid for \
    sbin"bin/git-dsf;bin/diff-so-fancy" zdharma/zsh-diff-so-fancy

zflai-msg "[zshrc] Zplugin block took ${(M)$(( SECONDS * 1000 ))#*.?} ms"

# set prompt
MYPROMPT=6

# Load perl5 local::lib
[[ -d ~/perl5/lib/perl5 ]] && eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

# Change dark-mode
if [[ "$OSTYPE" == darwin* ]]; then
    change_color() {
        C=$1; shift
        $HOME/lbin/ALL/iterm_change_colorpreset.py "${C}"
        eval base16_default-${C:l}
    }
    if (( $+commands[dark-mode] )); then
        val=$(dark-mode status)
        if [[ "${BASE16_THEME}" == *-light && "$val" == "on" ]]; then
            change_color Dark
        elif [[ "${BASE16_THEME}" == *-dark && "$val" == "off" ]]; then
            change_color Light
        fi
    fi
fi

if (( $+commands[ag] )); then
    alias ag='ag --pager less'
    export FZF_DEFAULT_COMMAND='ag -l -g ""'
    export FZF_DEFAULT_OPTS='--no-extended'
fi

(( $+commands[ip] )) && alias ip='ip -c'
(( $+commands[hub] )) && eval "$(hub alias -s)"
(( $+commands[plenv] )) && eval "$(plenv init - zsh)"
