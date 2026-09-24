#!/usr/bin/env bash
#
# ~/.bashrc: executed by bash(1) for non-login interactive shells.
# Merged from: alpinesky, m9, ruipryux, x270, x270-cygwin.

# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it.
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion matches all files
# and zero or more directories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# --- colors ----------------------------------------------------------------

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

# --- prompt ----------------------------------------------------------------

# let gpg pinentry see the tty (needed for interactive passphrase prompts)
if [ -t 0 ] && command -v tty >/dev/null 2>&1; then
    GPG_TTY=$(tty)
    export GPG_TTY
fi

# colorize unless the terminal is dumb (ANSI-only, no tput required)
case "${TERM:-dumb}" in
    dumb|"") color_prompt= ;;
    *)       color_prompt=yes ;;
esac

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
    if [ -f /etc/machine-id ]; then
        echo $((0x$(head -c 15 /etc/machine-id)))
    else
        # no machine-id: hash the hostname (also covers systems without hostid)
        local sum=0 i
        for (( i=0; i<${#HOSTNAME}; i++ )); do
            sum=$(( sum + $(printf "%d" "'${HOSTNAME:$i:1}") ))
        done
        echo $(( sum % 100 ))
    fi
}

function __makePS1() {
    local EXIT="$?"

if [ ! -n "${HOST_COLOR}" ]; then
        HOST_COLOR="\e[3$(( $(__getMachineId) % 6 + 1 ))m" # 31-36, ANSI foreground
    fi

    PS1=''

    PS1+="${debian_chroot:+($debian_chroot)}"

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

    # background jobs
    local NO_JOBS=$(jobs -p | wc -w)
    if [ "${NO_JOBS}" != "0" ]; then
        PS1+=" \[${BGreen}\][j${NO_JOBS}]\[${Color_Off}\]"
    fi

    # screen sessions
    local SCREEN_PATHS="/var/run/screens/S-$(whoami) /var/run/screen/S-$(whoami) /var/run/uscreens/S-$(whoami)"

    for screen_path in ${SCREEN_PATHS}; do
        if [ -d "${screen_path}" ]; then
            SCREEN_JOBS=$(ls "${screen_path}" | wc -w)
            if [ "${SCREEN_JOBS}" != "0" ]; then
                local current_screen="$(echo ${STY} | cut -d '.' -f 1)"
                if [ -n "${current_screen}" ]; then
                    current_screen=":${current_screen}"
                fi
                PS1+=" \[${BGreen}\][s${SCREEN_JOBS}${current_screen}]\[${Color_Off}\]"
            fi
            break
        fi
    done

    # git branch
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

    PS1+=" \[${Red}\]\\$\[${Color_Off}\]\\n" # command on the next line, red prompt

    __makeTerminalTitle
}

if [ "$color_prompt" = yes ]; then
    PROMPT_COMMAND=__makePS1
    PS2="\[${BPurple}\]>\[${Color_Off}\] " # continuation prompt
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ \n'
fi

unset color_prompt force_color_prompt

# --- ls / color support ----------------------------------------------------
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# --- programmable completion ------------------------------------------------
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# --- environment ------------------------------------------------------------
umask 022

# per-tool paths (machine specific; harmless elsewhere)
export PATH=$HOME/.opencode/bin:$PATH
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

export PATH

# --- user aliases and functions ---------------------------------------------
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

# --- system-info banner (once per terminal session) ---------------------------
if [ -x "$(command -v fastfetch)" ] && [ -z "$FASTFETCH_RAN" ]; then
    fastfetch
    export FASTFETCH_RAN=1
fi

# manygit
export PATH="$HOME/.local/bin:$PATH"