#!/usr/bin/env python

# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License, Version 2, as
# published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

from gi.repository import GLib

import dbus
import dbus.service
import dbus.mainloop.glib

import os
from subprocess import Popen
from urllib.parse import unquote

def open_file_manager(uri, select=False):
    # This uses the vifmrun wrapper from vifmimg (which support image previews).
    # If this is not desired, vifm can be used directly instead.
    termcmd = os.getenv("TERMCMD", "foot")
    args = [termcmd, '--app-id', 'floating', '--', 'vifm', '-c', 'only']

    if select:
        args.append('--select')

    path = unquote(str(uri))
    if path.startswith('file://'):
        path = path[7:]
    args.append(path)

    if os.fork() == 0:
        Popen(args)
        os._exit(0)
    else:
        os.wait()

class FmObject(dbus.service.Object):

    @dbus.service.method("org.freedesktop.FileManager1",
                         in_signature='ass', out_signature='')
    def ShowFolders(self, uris, startupId):
        open_file_manager(uris[0])

    @dbus.service.method("org.freedesktop.FileManager1",
                         in_signature='ass', out_signature='')
    def ShowItems(self, uris, startupId):
        open_file_manager(uris[0], select=True)

    @dbus.service.method("org.freedesktop.FileManager1",
                         in_signature='ass', out_signature='')
    def ShowItemProperties(self, uris, startupId):
        open_file_manager(uris[0], select=True)

    @dbus.service.method("org.freedesktop.FileManager1",
                         in_signature='', out_signature='')
    def Exit(self):
        mainloop.quit()

if __name__ == '__main__':
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    session_bus = dbus.SessionBus()
    name = dbus.service.BusName("org.freedesktop.FileManager1", session_bus)
    object = FmObject(session_bus, '/org/freedesktop/FileManager1')

    mainloop = GLib.MainLoop()
    mainloop.run()
