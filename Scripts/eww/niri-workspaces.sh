#!/bin/bash

# dynamically adjust titlebar & border for titling
# floating windows
#
#   tiling   -> titlebar: false, border_size: 2
#   floating -> titlebar: true,  border_size: 1

niri msg --json workspaces | jq --unbuffered -crM 'sort_by(.idx)'
niri msg --json event-stream | {
    while read -r event; do
        change=$(jq --unbuffered --raw-output 'keys_unsorted[0]' <<< "${event}")
        if [[ ${change} == WorkspaceActivated ]] || [[ ${change} == WorkspacesChanged ]]; then
            niri msg --json workspaces | jq --unbuffered -crM 'sort_by(.idx)'
        fi
    done
}

# vim: set et sts=4 sw=4:
