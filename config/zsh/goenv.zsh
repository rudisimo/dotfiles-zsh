# Use goenv binaries
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"

# Enable goenv hooks
if command -v goenv &> /dev/null; then
    eval "$(goenv init -)"

    # Use go installed binaries
    export PATH="$GOROOT/bin:$PATH"
    export PATH="$PATH:$GOPATH/bin"
fi
