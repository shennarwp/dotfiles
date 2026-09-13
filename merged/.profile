# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.

# if running bash, bring in the interactive shell config.
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes the user's private bin directories if they exist.
for d in "$HOME/bin" "$HOME/.local/bin"; do
    if [ -d "$d" ]; then
        PATH="$d:$PATH"
    fi
done
export PATH