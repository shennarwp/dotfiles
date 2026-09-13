# ~/.bash_profile: executed by bash(1) for login shells, on systems that
# look for it (e.g. macOS, Cygwin). Delegates to ~/.profile; the shell distro
# chain is: .bash_profile -> .profile -> .bashrc -> .bash_aliases/.bash_functions.

if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi