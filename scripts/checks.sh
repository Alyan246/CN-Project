#!/bin/bash
# Sanity checks. Run as root.
echo "--- Host A -> Host B (must FAIL before the VPN)"
ip netns exec ha ping -c2 -W1 10.2.0.10 && echo "UNEXPECTED: reachable" || echo "OK: unreachable"
echo "--- traceroute (stops at GW-A)"
ip netns exec ha traceroute -m3 -w1 10.2.0.10
echo "--- GW-A -> GW-B WAN (must work, ~20 ms)"
ip netns exec gwa ping -c3 203.0.113.2
echo "--- baseline throughput (~95 Mbit/s)"
ip netns exec gwa iperf3 -s -D
sleep 1
ip netns exec gwb iperf3 -c 198.51.100.2 -t 5
ip netns exec gwa pkill iperf3
