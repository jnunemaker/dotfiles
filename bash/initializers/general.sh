alias l='ls -lah'
alias o='open .'
alias httpdump='sudo tcpdump -i en0 -n -s 0 -w - | grep -a -o -E "Host\: .*|GET \/.*"'
