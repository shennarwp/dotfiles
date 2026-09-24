#!/usr/bin/env bash
#
# ~/.bash_functions: functions pulled out of the merged .bash_aliases
# (from ruipryux). Sourced from ~/.bashrc after .bash_aliases.

# checks if command $2 is installed and, if so, aliases $1 to it
function __add_command_replace_alias() {
    if [ -x "$(command -v $2 2>&1)" ]; then
        alias $1=$2
    fi
}

# nicer pager / editor if available
if [ -x "$(command -v most 2>&1)" ]; then
    alias less=most
    export PAGER=most
fi

if [ -x "$(command -v vim 2>&1)" ]; then
    export EDITOR=vim
fi

__add_command_replace_alias tail 'multitail'
__add_command_replace_alias df 'pydf'
__add_command_replace_alias traceroute 'mtr'
__add_command_replace_alias tracepath 'mtr'
__add_command_replace_alias top 'htop'

# display a matrix of terminal colors
function allcolors() {
    # credit to http://askubuntu.com/a/279014
    for x in 0 1 4 5 7 8; do
        for i in $(seq 30 37); do
            for a in $(seq 40 47); do
                echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
            done
            echo
        done
    done
    echo ""
}

# cd into the first repos dir that exists on this host (locations vary per host)
function rpo() {
    local d
    for d in ~/repo ~/Repo; do
        if [ -d "$d" ]; then
            cd "$d" || return
            return
        fi
    done
    echo "rpo: no repos dir found" >&2
}

# cd into the Windows-filesystem repos dir (WSL mount of C:)
function rpow() {
    local d
    for d in /mnt/c/repo /mnt/c/Repo; do
        if [ -d "$d" ]; then
            cd "$d" || return
            return
        fi
    done
    echo "rpow: no Windows repos dir found" >&2
}

# cloudflare speed test (100 MB), summarized in MB
function spd() {
    local out
    out=$(curl -o /dev/null -w "%{size_download} %{speed_download} %{time_total}" \
        -A "Mozilla/5.0" \
        -H "Origin: https://speed.cloudflare.com" \
        -H "Referer: https://speed.cloudflare.com/" \
        "https://speed.cloudflare.com/__down?bytes=100000000")
    read -r s v t <<< "$out"
    echo "  downloaded $(awk -v n="$s" 'BEGIN{printf "%.2f", n/1000000}') MB" \
         "in $(awk -v n="$t" 'BEGIN{printf "%.2f", n}') s," \
         "$(awk -v n="$v" 'BEGIN{printf "%.2f", n/1000000}') MB/s"
    date
}