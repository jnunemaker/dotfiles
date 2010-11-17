. ~/bin/dotfiles/bash/env
. ~/bin/dotfiles/bash/config
. ~/bin/dotfiles/bash/functions
. ~/bin/dotfiles/bash/aliases
. ~/bin/dotfiles/bash/git-completion

# Stuff you dont want to be in git repo can go in here and you can just git ignore
[[ -f ~/bin/dotfiles/bash/private ]] && . ~/bin/dotfiles/bash/private

[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

complete -C $rvm_scripts_path/rvm-completion.rb -o default rvm