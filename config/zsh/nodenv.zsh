# Use nodenv binaries
export NODENV_ROOT="$HOME/.nodenv"
export PATH="$NODENV_ROOT/bin:$PATH"

# Enable nodenv hooks
if command -v nodenv &> /dev/null; then
    eval "$(nodenv init -)"
fi
