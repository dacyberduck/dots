# /etc/skel/.bash_profile

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
if [[ -f ~/.bashrc ]] ; then
	. ~/.bashrc
fi
export XDG_DATA_DIRS=${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:/home/duck/.local/share/flatpak/exports/share
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-/tmp/${UID}/cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
export XDG_STATE_HOME=${XDG_STATE_HOME:-${HOME}/.local/state}
export XDG_BIN_HOME=${XDG_BIN_HOME:-${HOME}/.local/bin}

export XDG_PICTURES_DIR=${HOME}/Pictures
export XDG_PUBLICSHARE_DIR=${HOME}/Public
export XDG_DOWNLOAD_DIR=${HOME}/Downloads
export XDG_MUSIC_DIR=${HOME}/Music
export XDG_TEMPLATES_DIR=${HOME}/Templates
export XDG_DESKTOP_DIR=${HOME}/Desktop
export XDG_DOCUMENTS_DIR=${HOME}/Documents

export HISTFILE="${HOME}/.bash_history"
export HISTSIZE=1000
export HISTCONTROL='ignoreboth:erasedups'

export TERMCMD="footclient"
export TERMINAL="footclient"
export EDITOR="vim"
export BROWSER="firefox"
export PAGER="less"
