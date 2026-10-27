#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export XDG_CACHE_HOME=${XDG_CACHE_HOME:-/tmp/${UID}/cache}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
export XDG_BIN_HOME=${XDG_BIN_HOME:-${HOME}/.local/bin}
export PATH="${PATH}:${XDG_BIN_HOME}"

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
export QT_QPA_PLATFORMTHEME="gtk3"
export QT_QPA_PLATFORMTHEME_QT6="gtk3"

export TERMCMD="foot"
export TERMINAL="foot"
export EDITOR="vim"
export BROWSER="firefox"
export PAGER="less"
