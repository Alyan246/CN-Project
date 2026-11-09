# CN Project: VPN Lab

WireGuard (and later OpenVPN) site-to-site and remote-access VPN, built in Linux
network namespaces with netem for latency/bandwidth shaping.

## Topology
Host-A - GW-A ==(Internet router)== GW-B - Host-B, plus an RA client.
20 ms RTT, 100 Mbit/s bottleneck.

## Usage (as root)
    ./topo.sh               # build the lab
    scripts/checks.sh       # baseline checks, no VPN yet
    wg/up.sh                # generate keys, render configs, start WireGuard
    wg/down.sh && ./teardown.sh

Keys and rendered configs live in `keys/` and `build/` and are git-ignored.

## Layout
`wg/` WireGuard templates and scripts, `ovpn/` OpenVPN/easy-rsa, `scripts/`
measurement tools, `captures/` packet captures (not committed).



## Quick start

    git clone <repo-url>
    cd cn-vpn
    ./setup.sh          # installs packages, loads kernel modules, self-checks
    sudo ./topo.sh      # builds the lab
    sudo scripts/checks.sh   # baseline checks (Host A must NOT reach Host B)
    sudo wg/up.sh       # starts WireGuard
    sudo ip netns exec ha ping -c2 10.2.0.10   # should now succeed

Teardown: `sudo wg/down.sh && sudo ./teardown.sh`

Supported: Fedora, Arch, Debian/Ubuntu, openSUSE. Use a normal terminal, not a Flatpak or sandboxed one.



# TO RUN IN VSCODE TERMINAL DO: 
# 1) flatpak-spawn --host bash
# 2) sudo -S ./test.sh