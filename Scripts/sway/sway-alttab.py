#!/usr/bin/env python3
import i3ipc
import sys

def main():
    sway = i3ipc.Connection(auto_reconnect=True)

    # Alt+Tab window switching behavior
    for workspace in [ws for output in sway.get_tree().nodes for ws in output.nodes]:
        focus = workspace.find_focused()
        if focus is None:
            continue
        descendants = [d for d in workspace.descendants() if d.name is not None]
        focus = descendants.index(focus)
        focus = (focus + 1 if sys.argv[1] == "next" else focus - 1) % len(descendants)
        sway.command(f"[con_id={descendants[focus].id}] focus")
        sys.exit()

if __name__ == '__main__':
    main()

# vim: set et sts=4 sw=4:
