# /etc/skel/.bash_profile

### XDG directories
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg}
export XDG_DATA_DIRS=${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:/home/duck/.local/share/flatpak/exports/share
export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}
export XDG_CACHE_HOME="/tmp/${UID}/cache"
if ! test -d "${XDG_CACHE_HOME}"; then
    mkdir -p "${XDG_CACHE_HOME}"
    # symlink $HOME/.cache to $XDG_CACHE_HOME
    if ! test -d ${HOME}/.cache; then
        ln -s "${XDG_CACHE_HOME}" "${HOME}"/.cache
    fi
fi
export XDG_LOG_HOME="/tmp/${UID}/logs"
if ! test -d "${XDG_CACHE_HOME}/vim"; then
    mkdir -p "${XDG_CACHE_HOME}"/vim/{undodir,swapdir,viewdir}
fi
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

### program specific dirs
export W3M_DIR="${XDG_CONFIG_HOME}/w3m"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME}/password-store"
export LESSKEY="${XDG_CONFIG_HOME}/less/lesskey"
export LESSHISTFILE="${XDG_CACHE_HOME}/less/history"
export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
export XAUTHORITY="${XDG_CACHE_HOME}/Xauthority"

### others
export XKB_DEFAULT_LAYOUT=us
export WINEPREFIX="${HOME}/Games/wine"
export WINEDLLOVERRIDES="winemenubuilder.exe=d"
export DXVK_FRAME_RATE=30
export MOZ_ENABLE_WAYLAND=1
export HISTFILE="${HOME}/.bash_history"
export HISTSIZE=1000
export HISTCONTROL='ignoreboth:erasedups'

### Default applications
export TERMCMD="tym"
export TERMINAL="tym"
export EDITOR="vim"
export BROWSER="librewolf-bin"
export PAGER="less"

### PATH
export PATH="${PATH}:${XDG_BIN_HOME}:${HOME}/.cargo/bin"

### Default Session
if shopt -q login_shell; then
    [[ -f ~/.bashrc ]] && source ~/.bashrc
    if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_DESKTOP=sway
        export XDG_CURRENT_DESKTOP=sway
        dbus-run-session sway --unsupported-gpu
    fi
else
    exit 1 # Somehow this is a non-bash or non-login shell.
fi
