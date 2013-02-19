. ~/bin/dotfiles/bash/env
. ~/bin/dotfiles/bash/config
. ~/bin/dotfiles/bash/functions
. ~/bin/dotfiles/bash/aliases
. ~/bin/dotfiles/bash/git-completion

# Stuff you dont want to be in git repo can go in here and you can just git ignore
[[ -f ~/bin/dotfiles/bash/private ]] && . ~/bin/dotfiles/bash/private
