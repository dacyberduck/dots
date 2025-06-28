#!/bin/bash

swaymsg -m -t subscribe "['window']" --raw | {
    while read -r event; do
        change=$(jq -r '.change' <<< "${event}")
        if [[ ${change} == floating ]]; then
            con_id=$(jq -r '.container.id' <<< "${event}")
            con_type=$(jq -r '.container.type' <<< "${event}")
            if [[ ${con_type} == floating_con ]]; then
                swaymsg [con_id=${con_id}] border normal 1
            else
                swaymsg [con_id=${con_id}] border pixel 2
            fi
        fi
    done
}

# vim: set et sts=4 sw=4:
