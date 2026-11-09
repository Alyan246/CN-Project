#!/bin/bash
# One-shot setup for the VPN lab. Works on Fedora, Arch, Debian/Ubuntu, openSUSE.
set -e

if command -v dnf >/dev/null; then
  sudo dnf install -y wireguard-tools openvpn easy-rsa iperf3 tcpdump wireshark \
    traceroute iproute iproute-tc kernel-modules-extra git \
    python3-matplotlib python3-pandas
elif command -v pacman >/dev/null; then
  sudo pacman -S --needed --noconfirm wireguard-tools openvpn easy-rsa iperf3 tcpdump \
    wireshark-qt traceroute iproute2 git python-matplotlib python-pandas
elif command -v apt-get >/dev/null; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y wireguard-tools openvpn easy-rsa \
    iperf3 tcpdump tshark traceroute iproute2 git python3-matplotlib python3-pandas \
    "linux-modules-extra-$(uname -r)" 2>/dev/null \
  || sudo DEBIAN_FRONTEND=noninteractive apt-get install -y wireguard-tools openvpn easy-rsa \
    iperf3 tcpdump tshark traceroute iproute2 git python3-matplotlib python3-pandas
elif command -v zypper >/dev/null; then
  sudo zypper install -y wireguard-tools openvpn easy-rsa iperf tcpdump wireshark \
    traceroute iproute2 git python3-matplotlib python3-pandas
else
  echo "Unsupported distro. Install by hand: wireguard-tools openvpn easy-rsa iperf3 tcpdump traceroute iproute2 (with tc), git"
  exit 1
fi

getent group wireshark >/dev/null && sudo usermod -aG wireshark "$USER" || true
sudo modprobe wireguard 2>/dev/null || true
sudo modprobe sch_netem 2>/dev/null || true

# Self-check: tells you exactly what is missing
ok=1
chk() { if eval "$2" >/dev/null 2>&1; then echo "OK       $1"; else echo "MISSING  $1"; ok=0; fi; }
chk "network namespaces" "sudo ip netns add _t && sudo ip netns del _t"
chk "wireguard module"   "sudo ip link add _wg type wireguard && sudo ip link del _wg"
chk "netem (tc delay)"   "sudo ip netns add _n && sudo ip netns exec _n ip link add _d type dummy && sudo ip netns exec _n tc qdisc add dev _d root netem delay 1ms; r=\$?; sudo ip netns del _n; exit \$r"
for c in tc wg wg-quick openvpn iperf3 tcpdump traceroute; do chk "command $c" "command -v $c"; done

[ $ok -eq 1 ] && echo "Setup done. Next: sudo ./topo.sh" \
  || echo "Fix the MISSING items above (reboot once if a kernel module is missing), then rerun ./setup.sh"
