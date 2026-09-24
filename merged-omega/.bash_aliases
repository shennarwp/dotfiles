#!/usr/bin/env ash
#
# ~/.bash_aliases for the Onion Omega2 (OpenWrt, BusyBox ash).
# Deliberately BusyBox/ash-compatible ONLY — no GNU- or Debian-specific
# flags (e.g. rm -Iv --one-file-system, ls --color, apt). Sourced from
# ~/.profile, NOT bashrc/bash_functions (ash can't source those).

# --- navigation -----------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias .-='cd -'
alias cd..='cd ..'

# --- ls (busybox: no --color) ----------------------------------------------
export __LS_OPTIONS='-h'
alias ls='ls $__LS_OPTIONS -CF'
alias l='ls'
alias la='ls -a'
alias ll='ls -la'
alias sl='ls'

# --- terminal basics -------------------------------------------------------
alias cl='clear'
alias more='less'

alias vi='vi'                       # vim is not available on omega
alias v='vi'

# safer file operations (busybox-compatible flags only)
alias mkdir='mkdir -p -v'
alias md='mkdir'
alias mv='mv -i'
alias rm='rm -i'                    # no -I/--one-file-system/--preserve-root

# --- edit this config ------------------------------------------------------
alias esrc='vi ~/.profile'          # config file is .profile here
alias src='. ~/.profile'

# --- system tools ----------------------------------------------------------
alias df='df -h'
alias du='du -h'

# --- package management (OpenWrt opkg) --------------------------------------
alias uu='opkg update && opkg upgrade'
alias ai='opkg install'
alias ar='opkg remove'

# --- system info / fetch ----------------------------------------------------
alias pf='~/.pfetch'

# --- speed test (busybox wget: no custom headers) ---------------------------
alias spd='wget -O /dev/null "http://proof.ovh.net/files/100Mb.dat" ; date'