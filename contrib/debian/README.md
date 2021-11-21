
Debian
====================
This directory contains files used to package pigeond/pigeon-qt
for Debian-based Linux systems. If you compile pigeond/pigeon-qt yourself, there are some useful files here.

## pigeon: URI support ##


pigeon-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install pigeon-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your pigeon-qt binary to `/usr/bin`
and the `../../share/pixmaps/pigeon128.png` to `/usr/share/pixmaps`

pigeon-qt.protocol (KDE)

