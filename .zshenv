# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi


# define a trap to listen for USR1
# This allows me to reload the base16 theme in all interactive terminals
TRAPUSR1() {
    if [[ -o interactive ]]; then
        BASETHEME=~/.base16_theme
        test -r "${BASETHEME}" && source "${BASETHEME}"
    fi
}
