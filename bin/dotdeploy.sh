#!/bin/sh
# vim: et sw=4 ts=4

mode=$1

usage() {
    _exit=${1:-0}
    cat << EOF
Usage: $0 [help|local|bare|minivim|full]

Install dotfiles either from sshrc's local directrory, or from the net using git.

 help     help
 local    Install only the dotfiles brought with sshrc.
 bare     install ony the dotfiles and the minimal vim. don't install bash-it or
          the vim submodules
 minivim  don't install vim submodules
 full     install the full content of the dotfile git repos, and update
          vim.vcsh's submodules. Slow!

Modes outside of local need git and vcsh.

EOF
exit $_exit
}

case "$mode" in
    help) usage 0 ;;
    bare|minivim|local|full);;
    *) echo "Illegal mode option: $mode"
        usage 1
        ;;
esac

cd $HOME

if [ -z "$SSHHOME" ]; then
    _d=$(dirname $0)
    case "$_d" in
        */.sshrc.d*) SSHHOME=$(dirname $_d);;
    esac
fi

if [ "$mode" = "local" ]; then
    if [ -z "$SSHHOME" ]; then
        echo "FATAL: SSHHOME not set, can't get source directory."
        exit 1
    fi

    for dotf in $(find $SSHHOME -name '.*' -type f); do
        cp $dotf $HOME
    done
    exit 0
fi

if vcsh -h >/dev/null 2>&1; then
    vcsh=vcsh
else
    vcsh=$(which vcsh)

    if [ -z "$vcsh" ]; then
        if [ -n "$SSHHOME" ]; then
            if [ -x "$SSHHOME/.sshrc.d/vcsh" ]; then
                vcsh=$SSHHOME/.sshrc.d/vcsh
                mkdir -p $HOME/bin
                cp $vcsh $HOME/bin
            fi
        fi
    fi
fi
if [ -z "$vcsh" ]; then
    echo "ERROR: vcsh missing" >&2
    exit 1
fi

if ! git --version >/dev/null 2>&1; then
    echo "ERROR: git missing"
    exit 1
fi

set -e

mkdir -p originaldots

if [ -n "$SSHHOME" ] && [ -d "originaldots/.vim" ]; then
    rm -rf .vim
fi

for i in .bashrc .bash_profile .profile .vimrc .vim .dircolors .lessrc .Xresources .LESS_TERMCAP .lessfilter .bash_it; do
    if [ -e $i ]; then
        mv $i originaldots
    fi
done

if [ ! -d "$HOME/.config/vcsh/repo.d/dotfiles.vcsh.git" ]; then
    $vcsh clone https://github.com/folti/dotfiles.vcsh.git
else
    $vcsh dotfiles.vcsh pull
fi

git config --global include.path ~/.gitconfig_global

if [ ! -f $HOME/.hgrc ]; then
    touch $HOME/.hgrc
fi

if ! grep -q '%include .hgrc-global' $HOME/.hgrc; then
    echo '%include .hgrc-global' >> $HOME/.hgrc
fi

if [ ! -d "$HOME/.config/vcsh/repo.d/vim.vcsh.git" ]; then
    echo "Cloning vim.vcsh ..."
    $vcsh clone https://github.com/folti/vim.vcsh.git
else
    echo "Updating vim.vcsh ..."
    $vcsh vim.vcsh pull
fi

minimal_vims="bufferlist vim-pathogen vim-nginx bash-support awk-support perl-support spec Colour-Sampler-Pack vim-desert-warm-256"
case "$mode" in
    bare|minivim)
        for vims in $minimal_vims; do
            $vcsh vim.vcsh submodule update --init .vim/bundle/$vims
        done
        ;;
    *)
        $vcsh vim.vcsh submodule update --init --recursive
        $vcsh vim.vcsh up-subs
        ;;
esac

if [ "$mode" != "bare" ]; then
    echo "Pulling Bash-it"
    git clone -b devel https://github.com/folti/bash-it.git -- .bash_it
    if [ -f /etc/debian_version ]; then
        sudo apt-get install -y rcs
    fi
fi

if [ "$mode" = "full" ]; then
    if [ -f /etc/debian_version ]; then
        sudo apt-get install -y cmake exuberant-ctags g++ python-dev spellcheck
    fi
fi
