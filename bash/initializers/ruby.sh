# rbenv
which rbenv 2>&1 > /dev/null && eval "$(rbenv init -)"

alias irb='irb --readline -r irb/completion'
alias ss='script/server'
alias sr='script/run'
alias sf='script/fmt'
alias sb='script/bootstrap'
alias st='script/test'
alias sg='script/guard'
alias sb='script/bootstrap'
alias sw='script/watch'
alias sc='script/console'
alias sm='script/migrate'
alias migrate='rake db:migrate db:test:prepare'
alias remigrate='rake db:drop db:create db:migrate'
