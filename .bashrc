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
complete -cf doas
complete -F _command doas

export GPG_TTY=`tty`
export SSH_AUTH_SOCK=`gpgconf --list-dirs agent-ssh-socket`
gpgconf --launch gpg-agent
gpg-connect-agent /bye 1>&- 2>&-

# --- GPG Expiry Reminder ---
# Get the expiry timestamp of the Master Key (pub)
# field 7 in colon-format is the expiry timestamp
GPG_EXPIRY=$(gpg --list-keys --with-colons A198B1F9AFFAECF2 | grep "^pub" | cut -d: -f7)

if [ -n "$GPG_EXPIRY" ]; then
    CURRENT_DATE=$(date +%s)
    DAYS_LEFT=$(( ($GPG_EXPIRY - $CURRENT_DATE) / 86400 ))

    # If less than 14 days, shout in RED
    if [ "$DAYS_LEFT" -lt 14 ]; then
        echo -e "\033[0;31m" # Red Color
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "🚨 CRITICAL WARNING: GPG KEY EXPIRES IN $DAYS_LEFT DAYS 🚨"
        echo "        Plan your renewal ceremony NOW.       "
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo -e "\033[0m" # Reset Color
    # Optional: If less than 60 days, warn in YELLOW
    elif [ "$DAYS_LEFT" -lt 60 ]; then
        echo -e "\033[0;33m⚠️  Notice: GPG Key expires in $DAYS_LEFT days.\033[0m"
    fi
fi
