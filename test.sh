#!/bin/bash
TARGET="10.2.0.10"

echo -e "\nTearing down VPN interface to simulate VPN offline..."
sudo ./wg/down.sh > /dev/null 2>&1

echo -e "\nAttempting ping to $TARGET  while VPN is down..."
if ! sudo ip netns exec ha ping -c 1 -W 1 $TARGET > /dev/null 2>&1; then
    echo "   -> Connection failed: Host unreachable / Tunnel down."
fi

echo -e "\n Connecting VPN..."
sudo ./wg/up.sh > /dev/null 2>&1
sleep 1

echo -e "\n Testing connection to $TARGET over active VPN..."
if sudo ip netns exec ha ping -c 1 -W 2 $TARGET > /dev/null 2>&1; then
    echo "   -> SUCCESS: VPN Connected and traffic is flowing!"
else
    echo "   -> FAILURE: Connection still failed."
fi