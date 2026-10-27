#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

# alias
alias ls='ls -hF --color=auto'
alias la='ls -AhF --color=auto'
alias ll='ls -lhF1 --color=auto'
alias lla='ls -AlhF1 --color=auto'
alias ..='cd $OLDPWD'
alias cp='cp -ri'
alias mv='mv -i'
alias rm='rm -ri'
alias vi='vim -p'
alias vio='vim -O'

# Put your fun stuff here.
shopt -s autocd

export GPG_TTY=`tty`
export SSH_AUTH_SOCK=`gpgconf --list-dirs agent-ssh-socket`
gpgconf --launch gpg-agent
gpg-connect-agent /bye 1>&- 2>&-
