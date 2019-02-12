export HISTCONTROL=erasedups
export DOTFILES=$HOME/bin/dotfiles

alias reload='source $HOME/.bash_profile'

# Stuff you dont want to be in git repo can go in here and you can just git ignore
if [ -s "$DOTFILES/bash/private.sh" ]; then
  source "$DOTFILES/bash/private.sh"
fi

# Load all the goodies
for file in $DOTFILES/bash/initializers/*.sh; do
  source "$file"
done

# Set local bin, home bin as first paths to check no matter what.
export PATH=./bin:$HOME/bin:$PATH
