# ~/.profile for the Onion Omega2 (OpenWrt, BusyBox ash).
#
# Alias source of truth is the shared ~/.bash_aliases (merged dotfiles repo);
# it is ash-compatible, so we source it here. Machine-specific omega bits
# override it below. ~/.pfetch replaces the fastfetch/neofetch banner.

# --- shared merged aliases (ash-compatible) -------------------------------
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# --- PATH: opencode CLI + user bin ----------------------------------------
export PATH=$HOME/.opencode/bin:$PATH
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# --- omega-specific overrides ----------------------------------------------
unalias esrc src vim v vi spd 2>/dev/null
alias esrc='vi ~/.profile'   # config file is .profile here
alias src='. ~/.profile'
alias pf='~/.pfetch'
alias vim='vi'               # no vim on omega
alias spd='wget -O /dev/null "http://proof.ovh.net/files/100Mb.dat" ; date'   # busybox wget: no custom headers

# --- pfetch banner (once per login session) --------------------------------
if [ -x "$HOME/.pfetch" ] && [ -z "$PFETCH_RAN" ]; then
    "$HOME/.pfetch"
    export PFETCH_RAN=1
fi

# clear the terminal at logout (ash has no .bash_logout)
trap 'clear' EXIT