#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# erster teil der HOST variable ist der hostname
local _hostname=${HOST[(ws<.>)1]}
# alles danach ist der domainname
local _domainname=${HOST[(ws<.>)2,-1]}

# Set the list of directories that Zsh searches for programs.
path=(
  $HOME/lbin/ALL
  $HOME/lbin/${_hostname}
  $HOME/lbin/${_domainname}
  /usr/local/{bin,sbin}
  $path
)
# Remove non-existent paths
path=($^path(N))

manpath=(
  $HOME/perl5/man
  ${(s.:.)"$(manpath)"}
  $manpath
)
manpath=($^manpath(N))

infopath=(
  $infopath
)
infopath=($^infopath(N))

typeset -gU cdpath fpath mailpath path infopath manpath

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# use local profile if exists
test -f $HOME/.zprofile.local && . $HOME/.zprofile.local

# vim: ft=zsh
