# ~/.profile for the OpenWrt host (Onion Omega2, BusyBox ash).
#
# Sources ~/.bash_aliases (the merged-openwrt/ deliberate BusyBox/ash-compatible
# alias set) and sets up the openwrt bits: PATH for opencode, the
# pfetch banner, and a clear-on-logout trap. ~/.pfetch replaces the
# fastfetch/neofetch banner.

# --- openwrt aliases (BusyBox/ash-compatible, from merged-openwrt) -------
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# --- PATH: opencode CLI + user bin ------------------------------------------
# idempotent: .profile runs on every login shell, so a plain prepend would
# accumulate duplicates (busybox ash has no seq-less helpers worth calling)
for d in "$HOME/.opencode/bin" "$HOME/bin"; do
    if [ -d "$d" ]; then
        case ":$PATH:" in
            *":$d:"*) ;;
            *) PATH="$d:$PATH"; export PATH ;;
        esac
    fi
done

# --- pfetch banner (once per login session) --------------------------------
if [ -x "$HOME/.pfetch" ] && [ -z "$PFETCH_RAN" ]; then
    "$HOME/.pfetch"
    export PFETCH_RAN=1
fi

# clear the terminal at logout (ash has no .bash_logout)
trap 'clear' EXIT
