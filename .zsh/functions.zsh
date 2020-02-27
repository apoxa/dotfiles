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

# Load perl5 local::lib
[[ -d ~/perl5/lib/perl5 ]] && eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)
