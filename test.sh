#!/bin/bash
TARGET="10.2.0.10"

echo "=== Automated WireGuard Lab Test ==="

# 1. Load WireGuard kernel module if not already loaded
if ! lsmod | grep -q wireguard; then
    echo "Loading wireguard kernel module..."
    sudo modprobe wireguard || { echo "[-] Failed to load wireguard module"; exit 1; }
fi

# 2. Clean up any existing stale topology/namespaces
echo "Cleaning up existing network topology..."
if [ -f "./teardown.sh" ]; then
    sudo ./teardown.sh > /dev/null 2>&1
else
    for ns in ha gwa gwb ra; do
        sudo ip netns del $ns > /dev/null 2>&1
    done
fi

# 3. Build network topology (namespaces & veth pairs)
echo "[+] Building network topology..."
if [ -f "./topo.sh" ]; then
    sudo ./topo.sh > /dev/null 2>&1
elif [ -f "./setup.sh" ]; then
    sudo ./setup.sh > /dev/null 2>&1
else
    echo "[-] Error: Neither topo.sh nor setup.sh found!"
    exit 1
fi

# 4. Perform initial baseline ping (before VPN setup)
echo -e "\nAttempting ping to $TARGET while VPN is down..."
if ! sudo ip netns exec ha ping -c 1 -W 1 $TARGET > /dev/null 2>&1; then
    echo "   -> Connection failed: Host unreachable / Tunnel down."
fi

# 5. Bring up WireGuard VPN interfaces
echo -e "\nConnecting VPN..."
if [ -f "./wg/up.sh" ]; then
    sudo ./wg/up.sh > /dev/null 2>&1
else
    echo "[-] Error: ./wg/up.sh script not found!"
    exit 1
fi

# Wait for interface initialization and routing table propagation
sleep 3

# 6. Test connection over active VPN
echo -e "\nTesting connection to $TARGET over active VPN..."
if sudo ip netns exec ha ping -c 1 -W 2 $TARGET > /dev/null 2>&1; then
    echo -e "   -> SUCCESS: VPN Connected and traffic is flowing!\n"
    sudo ip netns exec ha ping -c 2 $TARGET
else
    echo -e "   -> FAILURE: Connection still failed."
    exit 1
fi