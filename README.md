# The vpn-start Project

Utility scripts for Virtual Private Network users.

### vpn-start.sh - Startup wrapper for the OpenConnect VPN client.

```
vpn-start.sh - Start VPN.
Usage: vpn-start.sh [flags]
Option flags:
  -t --type     - VPN type. Default: '2: Gdańsk'.
  -n --no-split - Don't use split route.
  -c --config   - Configuration file. Default: '/home/vpn-start.conf.sample'.
  -h --help     - Show this help and exit.
  -v --verbose  - Verbose execution.
  -g --debug    - Extra verbose execution.
  -d --dry-run  - Dry run, don't start VPN client.
VPN Types:
  1: London
  2: Gdańsk (default)
  3: Kalamata
Info:
  vpn-start.sh - Version 0.0
  Project Home: https://github.com/glevand/vpn-start
```

### find-host.sh - Search for hosts on a subnet.

```
find-host.sh - Search for hosts on a subnet.
Usage: find-host.sh [flags]
Option flags:
  -t --host     - Host to search for. Can be {all, any}.  Default: 'all'.
  -s --subnet   - Subnet to search.  Default: ''.
  -u --user     - User. Default: ''.
  -c --config   - Configuration file. Default: '/home/find-host.conf'.
  -h --help     - Show this help and exit.
  -v --verbose  - Verbose execution. Default: ''.
  -g --debug    - Extra verbose execution. Default: ''.
  -d --dry-run  - Dry run, don't do logins.
Info:
  find-host.sh - Version 0.0
  Project Home: https://github.com/glevand/vpn-start
```

## Build

To build use commands like these:

```
git clone https://github.com/glevand/vpn-start
cd vpn-start
./bootstrap
./configure
make
make install
```

## Licence & Usage

All files in the [The vpn-start Project](https://github.com/glevand/vpn-start), unless otherwise noted, are covered by an [MIT Plus License](https://github.com/glevand/vpn-start/blob/master/mit-plus-license.txt).  The text of the license describes what usage is allowed.
