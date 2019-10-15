#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# load zplug
if [[ -s "${ZDOTDIR:-$HOME}/.zplug/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zplug/init.zsh"
    zplug "voronkovich/gitignore.plugin.zsh"
    zplug "marzocchi/zsh-notify"
    zplug "knu/zsh-git-escape-magic"
    zplug "chriskempson/base16-shell", use:"scripts/profile_helper.sh", defer:0
    if ! zplug check; then
        zplug install
    fi
    zplug load
fi

unsetopt SHARE_HISTORY

# Add a function path
# NOTE: fpath doesn't recurse directories so they have to be add explicitily
functions_path=( themes functions completions )
functions_path=($HOME/.zsh/${^functions_path})        # prepend local dir

fpath=(
  /usr/local/share/zsh/site-functions
  $functions_path
  $fpath
)
fpath=($^fpath(N))
# Autoload functions
autoload -Uz $HOME/.zsh/functions/^*.*sh(:t)

# Set some aliases
if (( $+commands[ag] )); then
    alias ag='ag --pager less'
    export FZF_DEFAULT_COMMAND='ag -l -g ""'
    export FZF_DEFAULT_OPTS='--no-extended'
fi

if (( $+commands[ip] )); then
    alias ip='ip -c'
fi

if (( $+commands[hub] )); then
    eval "$(hub alias -s)"
fi

if (( $+commands[plenv] )); then
    eval "$(plenv init - zsh)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
