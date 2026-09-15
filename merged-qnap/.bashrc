#!/usr/bin/env bash
#
# ~/.bashrc: executed by bash(1) for non-login interactive shells.
# QNAP NAS variant of the merged dotfiles.

# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# QNAP PATH: keep as shipped by the platform.
export PATH=\
/bin:\
/sbin:\
/usr/bin:\
/usr/sbin:\
/usr/bin/X11:\
/usr/local/bin

# opencode CLI
export PATH=$HOME/.opencode/bin:$PATH

# include the user's private bin dir.
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi
export PATH

export USER=$(id -un)
export LOGNAME=$USER
export HOSTNAME=$(/bin/hostname)
export HISTSIZE=1000
export HISTFILESIZE=1000
export PAGER='/bin/more '
export EDITOR='/bin/vi'
export INPUTRC=/etc/inputrc
export DMALLOC_OPTIONS=debug=0x34f47d83,inter=100,log=logfile
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.png=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:'

# --- prompt (mirrors the other boxes, ANSI-only for QNAP) -------------------

Color_Off='\e[0m'
BWhite='\e[1;37m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Blue='\e[0;34m'
Purple='\e[0;35m'
BBlue='\e[1;34m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BRed='\e[1;31m'
BPurple='\e[1;35m'
UWhite='\e[4;37m'

# colorize unless the terminal is dumb
if [ "${TERM:-dumb}" != "dumb" ]; then
    color_prompt=yes
else
    color_prompt=
fi

FQDN=$(hostname -f)

function __makeTerminalTitle() {
    local title=''

    local CURRENT_DIR="${PWD/#$HOME/\~}"

    if [ -n "${SSH_CONNECTION}" ]; then
        title+="$(hostname):${CURRENT_DIR} [$(whoami)@${FQDN}]"
    else
        title+="${CURRENT_DIR} [$(whoami)]"
    fi

    echo -en '\033]2;'${title}'\007'
}

function __getMachineId() {
    # QNAP has no machine-id/hostid: hash the hostname.
    local sum=0 i
    for (( i=0; i<${#HOSTNAME}; i++ )); do
        sum=$(( sum + $(printf "%d" "'${HOSTNAME:$i:1}") ))
    done
    echo $(( sum % 100 ))
}

function __makePS1() {
    local EXIT="$?"

    if [ -z "${HOST_COLOR}" ]; then
        HOST_COLOR="\e[3$(( $(__getMachineId) % 6 + 1 ))m" # 31-36
    fi

    PS1=''

    if [ -n "${VIRTUAL_ENV}" ]; then
        local VENV=$(basename "$VIRTUAL_ENV")
        PS1+="\[${BWhite}\](${VENV}) \[${Color_Off}\]" # show virtualenv if in it
    fi

    if [ "${USER}" == "root" ]; then
        PS1+="\[${Red}\]" # root
    elif [ "${USER}" != "${LOGNAME}" ]; then
        PS1+="\[${Blue}\]" # normal user
    else
        PS1+="\[${Green}\]" # normal user
    fi
    PS1+="\u\[${Color_Off}\]"

    PS1+="\[${BWhite}\]@"
    PS1+="\[${UWhite}${HOST_COLOR}\]\h\[${Color_Off}\]" # host, colored by machine id

    PS1+=":\[${BYellow}\]\w" # working directory

    # git branch (git may be absent on the NAS; guarded)
    if [ -x "$(command -v git 2>&1)" ]; then
        local branch="$(git name-rev --name-only HEAD 2>/dev/null)"

        if [ -n "${branch}" ]; then
            local git_status="$(git status --porcelain -b 2>/dev/null)"
            local letters="$(echo "${git_status}" | grep -E ' \w ' | sed -e 's/^\s\?\(\w\)\s.*$/\1/')"
            local untracked="$(echo "${git_status}" | grep -F '?? ' | sed -e 's/^\?\(\?\)\s.*$/\1/')"
            local status_line="$(echo -e "${letters}\n${untracked}" | sort | uniq | tr -d '[:space:]')"
            PS1+=" \[${BBlue}\](${branch}"
                if [ -n "${status_line}" ]; then
                    PS1+=" ${status_line}"
                fi
            PS1+=")\[${Color_Off}\]"
        fi
    fi

    # exit code
    if [ "${EXIT}" != "0" ]; then
        PS1+=" \[${BRed}\][!${EXIT}]\[${Color_Off}\]"
    fi

    PS1+=" \[${Red}\]\\$\[${Color_Off}\]\\n" # red prompt, command on next line

    __makeTerminalTitle
}

if [ "$color_prompt" = yes ]; then
    PROMPT_COMMAND=__makePS1
    PS2="\[${BPurple}\]>\[${Color_Off}\] " # continuation prompt
else
    PS1='\u@\h:\w\$ \n'
fi

unset color_prompt

# Shared dotfiles from the merged repo.
for f in ~/.bash_aliases ~/.bash_functions; do
    if [ -f "$f" ]; then
        . "$f"
    fi
done

# system-info banner (once per session)
if [ -x "$(command -v neofetch)" ] && [ -z "$NEOFETCH_RAN" ]; then
    neofetch
    export NEOFETCH_RAN=1
fi