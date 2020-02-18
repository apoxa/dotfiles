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


