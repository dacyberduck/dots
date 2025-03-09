# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.
shopt -s autocd
complete -cf doas
complete -F _command doas

# alias
alias ls='ls -hF --color=auto'
alias la='ls -AhF --color=auto'
alias ll='ls -lhF1 --color=auto'
alias lla='ls -AlhF1 --color=auto'
alias ..='cd $OLDPWD'
alias cp='cp -ri'
alias mv='mv -i'
alias rm='rm -ri'
alias vi='vi -p'

