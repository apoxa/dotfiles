# load zsh plugins
PLUGMAN="${ZDOTDIR:-$HOME}/.zinit/bin/zinit.zsh"
if [[ -s "${PLUGMAN}" ]]; then
    source "${PLUGMAN}"
    autoload -Uz _zinit
    (( ${+_comps} )) && _comps[zinit]=_zinit
    source "${ZDOTDIR:-$HOME}/.zsh.bundle"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

unsetopt SHARE_HISTORY

# Try to source
for file in "${ZDOTDIR:-$HOME}/.zsh/aliases.zsh" \
            "${ZDOTDIR:-$HOME}/.zsh/functions.zsh" \
            "${ZDOTDIR:-$HOME}/.zsh/prompts.zsh"
do
    [ -s "${file}" ] && source "${file}"
done
