# Always use color output for `grep`
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias mgrep='egrep -IRn --exclude-dir=.svn --exclude-dir=.git'

# IP addresses
alias ipe="dig +short myip.opendns.com @resolver1.opendns.com"
alias ipn="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# Disable git pager
alias git="git --no-pager"
alias g="git"

# Configure ls as Ubuntu
alias l="ls -CF --group-directories-first"
alias la="ls -A --group-directories-first"
alias ll="ls -avlF --group-directories-first"
