export PATH=/usr/sbin
for DIRECTORY in /sbin /usr/bin /bin /usr/local/sbin /usr/local/bin /opt/puppetlabs/bin ; do
    if [ -d "$DIRECTORY" ]; then
        export PATH=${PATH}:$DIRECTORY
    fi
done

export EDITOR=vim
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
export LESSHISTSIZE=0
export PYTHONSTARTUP=~/.config/python/pythonrc
export SQLITE_HISTORY=/dev/null
export SYSTEMD_PAGER=
export VISUAL=vim

set -o vi
shopt -s cdspell
shopt -s checkwinsize
shopt -s histappend

prompt_command() {
    local RC="$?"
    local Default="\[\e[0m\]"
    local Red="\[\e[1;31m\]"
    local Green="\[\e[1;32m\]"
    local Blue="\[\e[1;34m\]"
    PS1="${Green}"
    if [ -n "$VIRTUAL_ENV" ]; then
        PS1+='($(basename "$VIRTUAL_ENV")) '
    fi
    PS1+="\h:${Blue}\w"
    local git_status=""
    local git_branch=""
    git_branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$git_branch" ]; then
        git_status=$(git status -s 2>/dev/null)
        if [ -z "$git_status" ]; then
            PS1+=" ${Green}${git_branch}"
        else
            PS1+=" ${Red}${git_branch}"
        fi
    fi
    if [ $RC != 0 ]; then
        PS1+=" ${Red}[$RC]"
    fi
    PS1+="${Default}\n"
    PS1+='$(if [ "$(id -u)" != "0" ]; then echo "$ "; else echo "# "; fi)'
}
PROMPT_COMMAND=prompt_command
umask 0022

export SSH_ENV="${HOME}/.ssh/ssh-agent.environment"
if [[ -f ${SSH_ENV} ]]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | awk -v n="${SSH_AGENT_PID}" '{if ($2 == n) {exit 145}}' > /dev/null
    if [[ $? -ne 145 ]]; then
        /usr/bin/ssh-agent > "${SSH_ENV}"
        chmod 600 "${SSH_ENV}"
        . "${SSH_ENV}" > /dev/null
        /usr/bin/ssh-add
    fi
else
    /usr/bin/ssh-agent > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
fi

if [ -f "${HOME}/.bash_aliases" ]; then . "${HOME}/.bash_aliases"; fi

if [[ $- == *i* ]]; then
    export PYVENVPATH=${HOME}/.python/venv/bin
    if [ -f "${PYVENVPATH}/activate" ]; then . "${PYVENVPATH}/activate"; fi
    if [ -f "${PYVENVPATH}/xonsh" ]; then exec "${PYVENVPATH}/xonsh"; fi
fi

