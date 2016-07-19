#!/bin/sh
# vim: et sw=4 ts=4

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
    $vcsh clone https://github.com/folti/vim.vcsh.git
else
    $vcsh vim.vcsh pull
fi

$vcsh vim.vcsh submodule update --init
$vcsh vim.vcsh up-subs

git clone -b devel https://github.com/folti/bash-it.git -- .bash_it
