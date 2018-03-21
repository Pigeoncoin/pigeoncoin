Sample init scripts and service configuration for pigeond
==========================================================

Sample scripts and configuration files for systemd, Upstart and OpenRC
can be found in the contrib/init folder.

    contrib/init/pigeond.service:    systemd service unit configuration
    contrib/init/pigeond.openrc:     OpenRC compatible SysV style init script
    contrib/init/pigeond.openrcconf: OpenRC conf.d file
    contrib/init/pigeond.conf:       Upstart service configuration file
    contrib/init/pigeond.init:       CentOS compatible SysV style init script

Service User
---------------------------------

All three Linux startup configurations assume the existence of a "pigeon" user
and group.  They must be created before attempting to use these scripts.
The OS X configuration assumes pigeond will be set up for the current user.

Configuration
---------------------------------

At a bare minimum, pigeond requires that the rpcpassword setting be set
when running as a daemon.  If the configuration file does not exist or this
setting is not set, pigeond will shutdown promptly after startup.

This password does not have to be remembered or typed as it is mostly used
as a fixed token that pigeond and client programs read from the configuration
file, however it is recommended that a strong and secure password be used
as this password is security critical to securing the wallet should the
wallet be enabled.

If pigeond is run with the "-server" flag (set by default), and no rpcpassword is set,
it will use a special cookie file for authentication. The cookie is generated with random
content when the daemon starts, and deleted when it exits. Read access to this file
controls who can access it through RPC.

By default the cookie is stored in the data directory, but it's location can be overridden
with the option '-rpccookiefile'.

This allows for running pigeond without having to do any manual configuration.

`conf`, `pid`, and `wallet` accept relative paths which are interpreted as
relative to the data directory. `wallet` *only* supports relative paths.

For an example configuration file that describes the configuration settings,
see `contrib/debian/examples/pigeon.conf`.

Paths
---------------------------------

### Linux

All three configurations assume several paths that might need to be adjusted.

Binary:              `/usr/bin/pigeond`  
Configuration file:  `/etc/pigeon/pigeon.conf`  
Data directory:      `/var/lib/pigeond`  
PID file:            `/var/run/pigeond/pigeond.pid` (OpenRC and Upstart) or `/var/lib/pigeond/pigeond.pid` (systemd)  
Lock file:           `/var/lock/subsys/pigeond` (CentOS)  

The configuration file, PID directory (if applicable) and data directory
should all be owned by the pigeon user and group.  It is advised for security
reasons to make the configuration file and data directory only readable by the
pigeon user and group.  Access to pigeon-cli and other pigeond rpc clients
can then be controlled by group membership.

### Mac OS X

Binary:              `/usr/local/bin/pigeond`  
Configuration file:  `~/Library/Application Support/Pigeon/pigeon.conf`  
Data directory:      `~/Library/Application Support/Pigeon`  
Lock file:           `~/Library/Application Support/Pigeon/.lock`  

Installing Service Configuration
-----------------------------------

### systemd

Installing this .service file consists of just copying it to
/usr/lib/systemd/system directory, followed by the command
`systemctl daemon-reload` in order to update running systemd configuration.

To test, run `systemctl start pigeond` and to enable for system startup run
`systemctl enable pigeond`

### OpenRC

Rename pigeond.openrc to pigeond and drop it in /etc/init.d.  Double
check ownership and permissions and make it executable.  Test it with
`/etc/init.d/pigeond start` and configure it to run on startup with
`rc-update add pigeond`

### Upstart (for Debian/Ubuntu based distributions)

Drop pigeond.conf in /etc/init.  Test by running `service pigeond start`
it will automatically start on reboot.

NOTE: This script is incompatible with CentOS 5 and Amazon Linux 2014 as they
use old versions of Upstart and do not supply the start-stop-daemon utility.

### CentOS

Copy pigeond.init to /etc/init.d/pigeond. Test by running `service pigeond start`.

Using this script, you can adjust the path and flags to the pigeond program by
setting the PIGEOND and FLAGS environment variables in the file
/etc/sysconfig/pigeond. You can also use the DAEMONOPTS environment variable here.

### Mac OS X

Copy org.pigeon.pigeond.plist into ~/Library/LaunchAgents. Load the launch agent by
running `launchctl load ~/Library/LaunchAgents/org.pigeon.pigeond.plist`.

This Launch Agent will cause pigeond to start whenever the user logs in.

NOTE: This approach is intended for those wanting to run pigeond as the current user.
You will need to modify org.pigeon.pigeond.plist if you intend to use it as a
Launch Daemon with a dedicated pigeon user.

Auto-respawn
-----------------------------------

Auto respawning is currently only configured for Upstart and systemd.
Reasonable defaults have been chosen but YMMV.
