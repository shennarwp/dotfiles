#!/usr/bin/env bash
#
# ~/.bash_aliases: aliases merged from alpinesky, m9, ruipryux, x270, x270-cygwin.
# Sourced from ~/.bashrc. Kept to plain aliases only; functions live in .bash_functions.

# --- navigation -----------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias .-='cd -'
alias cd..='cd ..'

# --- ls --------------------------------------------------------------
export __LS_OPTIONS='--color=auto -h'
alias ls='ls $__LS_OPTIONS -CF'
alias l='ls'
alias la='ls -a'
alias ll='ls -la'
alias sl='ls'

# --- terminal basics -----------------------------------------------------
alias cl='clear'
alias less='less -NR'
alias more='less'

alias vi='vim'
alias v='vi'

# safer file operations
alias mkdir='mkdir -p'
alias md='mkdir'
alias mv='mv -i'
alias rm='rm -i'

# --- edit this config -----------------------------------------------------
alias esrc='vi ~/.bashrc'
alias eal='vi ~/.bash_aliases'
alias esf='vi ~/.bash_functions'
alias src='source ~/.bashrc'

# --- system tools --------------------------------------------------------
alias ht='htop'
alias bt='btm'
alias df='df -h'
alias du='du -h'
alias nm='~/bin/nmon'
alias yt='~/bin/ytop'

# --- package management ----------------------------------------------------
alias uu='sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y'
alias uug='sudo apt update -y && sudo apt upgrade && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y'

# --- docker ---------------------------------------------------------------
alias dc='docker'
alias dco='docker compose'
alias dcip="docker ps -q | xargs -n 1 docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{ .Name }}' | sed 's/ \// /'"
alias dry='docker run --name dry --rm -it -v /var/run/docker.sock:/var/run/docker.sock -e DOCKER_HOST= $DOCKER_HOST moncho/dry'
alias ctop='docker run --rm -ti --name=ctop --volume /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop:latest'

# --- system info / fetch scripts -------------------------------------------
alias nf='neofetch'
alias fh='~/script/fet.sh'
alias pf='~/script/pfetch'
alias uf='~/script/ufetch'
alias tq='~/torque'

# --- wake on lan -----------------------------------------------------------
alias wakex41='wakeonlan 00:0A:E4:3B:D9:6D'

# --- windows / cygwin ----------------------------------------------------
alias chtw="cd ~/../../cygdrive/c/Users/ruip_/OneDrive/Dokumen/HTW"

# Sublime Text: WSL mounts windows drives on /mnt/c, Cygwin uses cygdrive
if [ -d /mnt/c ]; then
    alias subl='/mnt/c/Program\ Files/Sublime\ Text/sublime_text.exe'
else
    alias subl='C:/Program\ Files/Sublime\ Text/sublime_text.exe'
fi
alias sb='subl'
alias spt='C:/Program\ Files/spotify-tui/spt.exe'
alias rpo='cd C:/repos'
alias jpt='jupyter notebook'
alias stg='stack ghci'

# --- git ------------------------------------------------------------------
alias g='git'
alias gcl='g clone'
alias gad='g add'
# status
alias gs='g status'
alias gst='gs'
# log
alias gl="g log --pretty=format:'%Cred%h%Creset %Cgreen(%cr)%Creset - %C(yellow)%d%Creset %s' --abbrev-commit --date=relative"
alias glg="g log --graph --pretty=format:'%Cred%h%Creset %Cgreen(%cr)%Creset - %C(yellow)%d%Creset %s' --abbrev-commit --date=relative"
# branch
alias gb='g branch'
alias gbr='gb'
# checkout
alias gch='g checkout'
alias gck='gch'
alias gchk='gch'
# commit
alias gcm='g commit'
# push
alias gps='git push'
alias gpso='gps origin'
# pull
alias gpl='git pull'
alias gplo='gpl origin'
# --- QNAP override: /bin/ls (busybox) has no --color support -----------------
unset LS_OPTIONS 2>/dev/null
export __LS_OPTIONS='-h'
