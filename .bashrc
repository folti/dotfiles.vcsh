# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

if [ -f "$HOME/.profile_env" ]; then
    . "$HOME/.profile_env"
fi

if [ -f ~/.bash_env ]; then
    . ~/.bash_env
fi

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"
fi

# If not running interactively, don't do anything:
[ -z "$PS1" ] && return

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profiles
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

__set_dircolors() {
    local _dcfile="$1"
    if [ -f "$_dcfile" ]; then
        eval $(dircolors "$_dcfile")
    fi
}
# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ] && [ -n "$TERM" ]; then
    if [ -x /usr/bin/dircolors ]; then
        case "$TERM" in
            *256color|*256color-*)
                __set_dircolors "$HOME/.dircolors256"
                ;;
            dumb);;
            *)
                __set_dircolors "$HOME/.dircolors"
                ;;
        esac
    fi

    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*|screen*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
        ;;
    *)
        ;;
    esac
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" -a -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Comment in the above and uncomment this below for a color prompt
PS1='$? ${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

alias termreset='echo -ne "\017\012";reset'

listdlls() {
    while [ -n "$1" ]; do
        if [ -f "$1" ];then
            echo "$1:"
            objdump -x "$1" | sed -n -e 's/.*DLL Name: /  /p'
        fi
        shift
    done
}

gensnapshot () {
    date "+%Y%m%d+%H%M"
}

__screen=`which screen`
if [ -n "$__screen" ]; then
    SCREEN_TERM=""
    case "$TERM" in
        *-256color*|*256color-*)
            SCREEN_TERM="-T screen-256color"
            ;;
    esac

    alias screen="$__screen $SCREEN_TERM"
fi
unset __screen

#export win bbug heirloom heirman gensnapshot listdlls
export gensnapshot listdlls






# very long bash history
HISTSIZE=4000
HISTFILESIZE=4000
export HISTSIZE HISTFILESIZE
# allow varoius bash instances to append their history to the histfile.
shopt -s histappend
# don't put duplicate lines in the history. See bash(1) for more options
#export HISTCONTROL=ignoredups

alias xtitle='echo -ne "\033]0;$1\007"'
alias hsearch='history | grep '
alias hgrep='history | grep '

alias gmutt='mutt -F ~/.muttrc-gmail'
alias hunkey='setxkbmap -option grp:switch,grp:shifts_toggle,grp_led:scroll us,hu basic,qwerty'




# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f $HOME/.LESS_TERMCAP ]; then
    source $HOME/.LESS_TERMCAP
fi

# load bash-it
if [ -f $HOME/.bash_it_rc ]; then
    source $HOME/.bash_it_rc
fi

case "$HISTCONTROL" in
    *ignoreboth*);;
    *)
        export HISTCONTROL="$HISTCONTROL:ignoreboth"
        ;;
esac

# MC likes to pollute it's subshell's history
export HISTIGNORE='cd "\`printf*'

# vim: expandtab
