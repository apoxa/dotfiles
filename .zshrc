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

# load antigen
_ANTIGEN_COMP_ENABLED=0
source "${HOME}/.antigen/antigen.zsh"
antigen bundle voronkovich/gitignore.plugin.zsh
antigen bundle marzocchi/zsh-notify
antigen bundle knu/zsh-git-escape-magic
antigen bundle chriskempson/base16-shell
antigen apply

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
export FZF_COMPLETION_OPTS='+c -x'
