#!/usr/bin/env python3

# TODO: mru sorted window list

import argparse
import subprocess
import sys
import shutil
from dataclasses import dataclass

@dataclass
class WindowData:
    ws: str
    id: str
    app_id: str
    name: str


@dataclass
class Windows:
    windows: list[WindowData]

    def append(self, window: WindowData):
        self.windows.append(window)

    def construct_dmenu_list(self) -> str:
            return "\n".join(
                f"{win.ws} | {win.app_id} | {win.name}" for win in self.windows
            )

    def get_id_by_index(self, index):
        return self.windows[int(index)].id


def get_windows(window_type):
    """Get the list of windows based on the specified type."""
    swaymsg_command = "swaymsg -t get_tree"
    if window_type == "all":
        jq_filter = (
            '.nodes[].nodes[] | (.name + "|||" + '
            ' ((.floating_nodes[], .nodes[], .nodes[].nodes[]) '
            '| select((.app_id != null) or (.name != null)) | '
            '(.id | tostring) + "|||" + .app_id + "|||" + .name))'
        )
        # jq_filter = (
        #     "recurse(.nodes[]?) | recurse(.floating_nodes[]?) | "
        #     'select(.type == "con"), select(.type == "floating_con") | '
        #     '(.id | tostring) + "|||" + .app_id + "|||" + .name'
        # )
    elif window_type == "regular":
        jq_filter = (
            '.nodes[].nodes[] | select(.name != "__i3_scratch") | '
            '(.name + "|||" + ((.nodes[], .nodes[].nodes[]) '
            '| select((.app_id != null) or (.name != null)) | '
            '(.id | tostring) + "|||" + .app_id + "|||" + .name))'
        )
        # jq_filter = (
        #     'recurse(.nodes[]?) | select(.type == "con") | '
        #     '(.id | tostring) + "|||" + .app_id + "|||" + .name'
        # )
    elif window_type == "floating":
        jq_filter = (
            '.nodes[].nodes[] | select(.name != "__i3_scratch") '
            '| (.name + "|||" + (.floating_nodes[] '
            '| select((.app_id != null) or (.name != null)) | '
            '(.id | tostring) + "|||" + .app_id + "|||" + .name))'
        )
        # jq_filter = (
        #     ".nodes[].nodes[].floating_nodes[] | "
        #     '(.id | tostring) + "|||" + .app_id + "|||" + .name'
        # )
    elif window_type == "scratch":
        jq_filter = (
            '.nodes[].nodes[] | select(.name == "__i3_scratch") | '
            '(.name + "|||" + (.floating_nodes[] | '
            'select((.app_id != null)'' or (.name != null)) | '
            '(.id | tostring) + "|||" + .app_id + "|||" + .name))'
        )
        # jq_filter = (
        #     'recurse(.nodes[]?) | select(.name == "__i3_scratch") | '
        #     'recurse(.floating_nodes[]?) | select(.type == "floating_con") | '
        #     '(.id | tostring) + "|||" + .app_id + "|||" + .name'
        # )
    else:
        raise_error_dmenu(f'Invalid type "{window_type}"')
        sys.exit(1)

    command = (
        f"{swaymsg_command} | jq -r '{jq_filter}' | grep -v '^[0-9]\\+|\\{{6\\}}$' | column -C right -d -t -o '|' -s '|||'"
    )
    result = subprocess.run(command, shell=True, capture_output=True, text=True)

    if result.returncode != 0:
        if result.stderr == "":
            raise_error_dmenu("Warning: No Results")
        else:
            raise_error_dmenu(
                f"Error: executing command failed: {result.stderr}"
            )
        sys.exit(1)

    return parse_window_output(result.stdout)


def parse_window_output(output):
    """Parse the output of the swaymsg command into a structured list of dictionaries."""
    windows = Windows(windows=[])
    for line in output.splitlines():
        parts = line.split("|||")
        if len(parts) >= 3:
            windows.append(WindowData(ws=parts[0], id=parts[1], app_id=parts[2],
                                      name=parts[3]))
    return windows


def dmenu(dmenu_str, promot):
    try:
        selected = subprocess.run(
            [
                "tofi",
                "--anchor=top",
                "--width=1366",
                "--height=256",
                "--horizontal=false",
                "--print-index=true",
                f"--prompt-text={promot}",
            ],
            input=dmenu_str,
            text=True,
            capture_output=True,
        ).stdout.strip()

    except FileNotFoundError:
        print("Error: rofi is not installed.", file=sys.stderr)
        sys.exit(1)
    return selected


def dmenu_run(dmenu_str, promot):
    try:
        selected_index = None
        selected_index = dmenu(dmenu_str, promot)
    except ValueError:
        print("Error: no window selected.", file=sys.stderr)
        sys.exit(0)
    return selected_index


def raise_error_dmenu(err):
    dmenu_run(err, "")
    print(err, file=sys.stderr)


WINDOW_TPYES = ["all", "floating", "scratch", "regular"]


def main():
    parser = argparse.ArgumentParser(
        description="List and select windows using swaymsg and dmenu launchers like fuzzel and rofi."
    )
    parser.add_argument(
        "-t",
        "--type",
        type=str,
        default="all",
        choices=WINDOW_TPYES,
        help='Type of window to list. Defaults to "all".',
    )
    args = parser.parse_args()

    WINDOW_TYPE = args.type

    windows = get_windows(WINDOW_TYPE)

    if not windows:
        raise_error_dmenu("Error: No windows found")
        sys.exit(1)

    # Build dmenu list
    windows_dmenu_str = windows.construct_dmenu_list()
    dmenu_promot = f"{str.capitalize(WINDOW_TYPE)} Windows:"

    # Run dmenu
    selected_index = dmenu_run(windows_dmenu_str, dmenu_promot)
    if selected_index != "":
        selected_index = str(int(selected_index) - 1)

    # Tell sway to focus said window
    if selected_index:
        window_id = windows.get_id_by_index(selected_index)
        subprocess.run(["swaymsg", f"[con_id={window_id}] focus"])


if __name__ == "__main__":
    main()

# vim: set et sts=4 sw=4:
