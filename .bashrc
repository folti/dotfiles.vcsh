# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ] && [ -n "$TERM" ]; then
    case "$TERM" in
        *256colors)
            eval $(dircolors ~/.dircolors256)
            ;;
        dumb);;
        *)
            eval $(dircolors ~/.dircolors)
            ;;
    esac

    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'

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




squid(){
	
	
	
	gconftool --type int --set /system/http_proxy/port 3128
}

privoxy() {
	export http_proxy=http://localhost:8118
	
	gconftool --type string --set /system/http_proxy/host "localhost"
	gconftool --type int --set /system/http_proxy/port 8118
}

export squid privoxy 

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




eval "$(lesspipe)"

if [ -f $HOME/.bash_it_rc ]; then
	source $HOME/.bash_it_rc
fi
export HISTCONTROL="$HISTCONTROL ignorespace"
# turn off X's bell 
#if [ "$DISPLAY" ]; then
#	xset b 0
#fi

#alias nobell='echo -ne "\x1b[11;0]"'
#
#function bell(){
#  if [ $1 ];then 
#     usec=$1
#  else
#    usec=100
#  fi
#  echo -ne "\x1b[11;$usec]"
#}
#export bell
#nobell

''






#leftmouse() {
#	gconftool --type bool --set /desktop/gnome/peripherals/mouse/left_handed true
#}
#
#rightmouse() {
#	gconftool --type bool --set /desktop/gnome/peripherals/mouse/left_handed false
#}
#leftmouse rightmouse


#alias tla_distclean='if [ -d debian ] && [ -d "{arch}" ] ;then rm -rf \{arch\} && find . -type d -name .arch-ids -print0 | xargs -0 rm -rf;fi'

#tla_rendir() {
#	if [ -n "$1" ] && [ -f "$1/debian/changelog" ];then 
#		f=`head -1 "$1/debian/changelog" | sed -e "s/.*(//" -e "s/).*//"`
#		pkgname=`echo "$1" | sed -e 's/\-\-.*//'`
#		new=$pkgname"_"$f
#		mv "$1" "$new"
#	fi
#}
#export tla_rendir













#}

#win() {
#	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/wine/lib
#	export PATH=$PATH:/usr/local/wine/bin
#}

#heirloom () {
#	export PATH=/usr/5bin:/usr/ccs/bin:$PATH
#	export MANPATH=/usr/share/man/5man/:usr/ccs/share/man:$MANPATH
#}

#heirman () {
#	export MANPATH=/usr/share/man/5man/:usr/ccs/share/man:$MANPATH
#}


