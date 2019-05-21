# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


hosttype=$(uname -s | tr '[A-Z]' '[a-z]')

if [ -f "$HOME/.profile_env" ]; then
    . "$HOME/.profile_env"
fi

if [ -f ~/.bash_env ]; then
    . ~/.bash_env
fi

__terminfocheck() {
    _fch=$(echo "$1" | head -c 1)

    for _d in $HOME/.terminfo /usr/share/terminfo/ /lib/terminfo/; do
        if [ -f "$_d/$_fch/$1" ]; then
            unset _fch
            return 0
        fi
    done
    unset _fch
    return 1
}

__set_term() {
     _nuterm=$1
    if [ -n "$_nuterm" ] && __terminfocheck "$_nuterm"; then
        TERM=$_nuterm
        export TERM
        unset _nuterm
    fi
    unset _nuterm
}

if [ "$TERM" != "dumb" ] && [ -n "$TERM" ]; then
    # ripped from here: http://fedoraproject.org/wiki/Features/256_Color_Terminals#Scope
    # try to detect the terminal emulators that support 256 colors, but don't
    # tell it in their TERM.
    local256="$COLORTERM$XTERM_VERSION$ROXTERM_ID$KONSOLE_DBUS_SESSION"
    if [ -n "$local256" ]; then
        case "$TERM" in
            'xterm') TERM=xterm-256color;;
            'screen') TERM=screen-256color;;
            'Eterm') TERM=Eterm-256color;;
        esac
        export TERM
    fi
    unset local256

    # check if we have the *-unicode-* terminfos
    case "$TERM" in
        *-unicode-*)
            if ! __terminfocheck "$TERM"; then
                _nuterm=$(echo $TERM | sed -e 's/-unicode//')
                __set_term "$_nuterm"
                unset _nuterm
            fi
        ;;
    esac

    __TERM_COLORS=$(tput colors 2>/dev/null|| echo 8)
    case "$TERM" in
        *-256color*)
            if ! __terminfocheck "$TERM" || [ 256 -gt $__TERM_COLORS ]; then
                _nuterm=${TERM%%-256color*}
            fi
            ;;
        *-88color*)
            __terminfo_color=88
            if ! __terminfocheck "$TERM" || [ 88 -gt $__TERM_COLORS ]; then
                _nuterm=${TERM%%-88color*}
            fi
            ;;
    esac
    __set_term "$_nuterm"
    unset _nuterm

    for _t in $TERM xterm vt100; do
        if __terminfocheck "$_t"; then
            TERM=$_t
            export TERM
            break
        fi
    done

    # ripped from here: http://fedoraproject.org/wiki/Features/256_Color_Terminals#Scope
    # force 256 colors under screen.
    if [ -n "$TERMCAP" ]; then
        case "$TERM" in
            screen-256color*)
                TERMCAP=$(echo "$TERMCAP" | sed -e 's/Co#8/Co#256/g')
                export TERMCAP
                ;;
        esac
    fi
    unset _t
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

    case "$hosttype" in
        linux)
            alias ls='ls --color=auto'
            alias dir='ls --color=auto --format=vertical'
            alias vdir='ls --color=auto --format=long'

            alias grep='grep --color=auto'
            alias fgrep='fgrep --color=auto'
            alias egrep='egrep --color=auto'
            ;;
    esac

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
        ;;
    screen*)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        ;;
    *)
        ;;
    esac
fi

case "$hosttype" in
    linux)
        # some more ls aliases
        alias ll='ls -l'
        alias la='ls -A'
        alias l='ls -CF'
        ;;
esac

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" -a -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Comment in the above and uncomment this below for a color prompt
if [ "$USER" = "root" ] || [ "$UID" = "0" ] || [ "$(id -u)" = "0" ]; then
    PS1='$? ${debian_chroot:+($debian_chroot)}\[\033[0;1;37;41m\]\u\[\033[0;37;41m\]@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='$? ${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\u\033[00m\]@\[\033[00;33m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

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

__screen=`which screen 2>/dev/null`
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

set_screen_title(){
    _title=$1

    case "$TERM" in
        screen*) printf '\033k%s\033\\' "$_title" ;;
    esac
}

get_xres() {
    s=$(xdpyinfo | grep dimensions | awk '{print $2}' | awk -Fx '{print $1, $2}')
    read X11_X X11_Y <<<"$s"
}

get_rdesktop_res() {
    get_xres
    if [ $X11_X -le 1600 ]; then
        RES='90%'
    else
        RES='1600x900'
    fi
    echo $RES
    unset X11_X X11_Y
}

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

# very long bash history
HISTSIZE=20000
HISTFILESIZE=20000
export HISTSIZE HISTFILESIZE
# allow varoius bash instances to append their history to the histfile.
shopt -s histappend
# don't put duplicate lines in the history. See bash(1) for more options
#export HISTCONTROL=ignoredups
case "$HISTCONTROL" in
    *ignoreboth*);;
    *)
        export HISTCONTROL="$HISTCONTROL:ignoreboth"
        ;;
esac

# load bash-it
if [ -f $HOME/.bash_it_rc ]; then
    source $HOME/.bash_it_rc
    unset pass
fi

function git_clean_untracked () {
    ofs=$IFS
    IFS='
'
    for obj in `git status --porcelain | grep '^??'| cut -f2- -d' '`; do
        if [ -d "$obj" ]; then
            rm -rf "$obj"
        else
            rm -f "$obj"
        fi
    done
    IFS=$ofs
}

#cuz we are lazy
shopt -s autocd

# MC likes to pollute it's subshell's history
export HISTIGNORE='&:exit:clear:ls:mc:cd "\`printf*'

if [ -f "$HOME/.keychain/${HOSTNAME}-sh" ]; then
    . "$HOME/.keychain/${HOSTNAME}-sh"
fi

if [ -f "$HOME/.keychain/${HOSTNAME}-sh-gpg" ]; then
    . "$HOME/.keychain/${HOSTNAME}-sh-gpg"
fi

export SSH_SOCKS_PORT=${SSH_SOCKS_PORT:-9999}
alias ncssh='ssh -o ProxyCommand="nc -X 5 -x localhost:$SSH_SOCKS_PORT %h %p"'
alias ncscp='scp -o ProxyCommand="nc -X 5 -x localhost:$SSH_SOCKS_PORT %h %p"'
alias ncsftp='sftp -o ProxyCommand="nc -X 5 -x localhost:$SSH_SOCKS_PORT %h %p"'
# vim: expandtab
