#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
#
# Environment Variables
export EDITOR='nvim'

# Git configuration
git config --global alias.gr 'log --graph --full-history --all --color --pretty=tformat:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s%x20%x1b[33m(%an)%x1b[0m"'
git config --global color.diff auto
git config --global color.status auto

# Z setup
. /home/namalkanti/Documents/utils/z/z.sh

#Fzf/xplr variables
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS="--tmux"
