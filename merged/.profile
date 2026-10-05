# shellcheck disable=all
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
# idempotent: .profile is sourced again by every login shell (and by
# .bash_profile), so a plain prepend would duplicate entries in $PATH.
for d in "$HOME/bin" "$HOME/.local/bin"; do
    if [ -d "$d" ]; then
        case ":$PATH:" in
            *":$d:"*) ;;
            *) PATH="$d:$PATH" ;;
        esac
    fi
done
export PATH
