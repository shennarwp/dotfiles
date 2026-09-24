# ~/.profile for the Onion Omega2 (OpenWrt, BusyBox ash).
#
# Sources ~/.bash_aliases (the merged-omega/ deliberate BusyBox/ash-compatible
# alias set) and sets up the omega-specific bits: PATH for opencode, the
# pfetch banner, and a clear-on-logout trap. ~/.pfetch replaces the
# fastfetch/neofetch banner.

# --- omega aliases (BusyBox/ash-compatible, from merged-omega) -----------
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# --- PATH: opencode CLI + user bin ----------------------------------------
export PATH=$HOME/.opencode/bin:$PATH
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# --- pfetch banner (once per login session) --------------------------------
if [ -x "$HOME/.pfetch" ] && [ -z "$PFETCH_RAN" ]; then
    "$HOME/.pfetch"
    export PFETCH_RAN=1
fi

# clear the terminal at logout (ash has no .bash_logout)
trap 'clear' EXIT