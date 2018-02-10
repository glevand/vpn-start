# vpn-start

Startup wrapper for the OpenConnect VPN client.

### vpn-start.sh Usage

```
vpn-start.sh - Start VPN.
Usage: vpn-start.sh [flags]
Option flags:
  -t --type     - VPN type. Default: '2: BBB'.
  -n --no-split - Don't use split route.
  -c --config   - Configuration file. Default: 'vpn-start.conf.sample'.
  -h --help     - Show this help and exit.
  -v --verbose  - Verbose execution.
  -g --debug    - Extra verbose execution.
  -d --dry-run  - Dry run, don't start VPN client.
VPN Types:
  1: AAA
  2: BBB (default)
  3: CCC
Info:
  vpn-start.sh - Version 0.0
  Project Home: https://github.com/glevand/vpn-start
```

## Licence & Usage

All files in the [vpn-start project](https://github.com/glevand/vpn-start), unless otherwise noted, are covered by an [MIT Plus License](https://github.com/glevand/vpn-start/blob/master/mit-plus-license.txt).  The text of the license describes what usage is allowed.
