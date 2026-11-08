#!/bin/bash
# Builds the lab topology. Run as root.
set -e
for n in ha gwa rinet gwb hb ra; do ip netns add $n; ip -n $n link set lo up; done

mklink() { # ns1 if1 ip1 ns2 if2 ip2
  ip link add "$2" type veth peer name "$5"
  ip link set dev "$2" netns "$1"
  ip link set dev "$5" netns "$4"
  ip -n "$1" addr add "$3" dev "$2"
  ip -n "$4" addr add "$6" dev "$5"
  ip -n "$1" link set dev "$2" up
  ip -n "$4" link set dev "$5" up
}
mklink ha  eth0 10.1.0.10/24     gwa lan 10.1.0.1/24
mklink hb  eth0 10.2.0.10/24     gwb lan 10.2.0.1/24
mklink gwa wan  198.51.100.2/30  rinet a 198.51.100.1/30
mklink gwb wan  203.0.113.2/30   rinet b 203.0.113.1/30
mklink ra  wan  192.0.2.2/30     rinet c 192.0.2.1/30

for n in gwa gwb rinet; do ip netns exec $n sysctl -qw net.ipv4.ip_forward=1; done
ip -n ha  route add default via 10.1.0.1
ip -n hb  route add default via 10.2.0.1
ip -n gwa route add default via 198.51.100.1
ip -n gwb route add default via 203.0.113.1
ip -n ra  route add default via 192.0.2.1

# 20 ms RTT (10 ms per egress), 100 Mbit/s bottleneck
for i in a b c; do ip netns exec rinet tc qdisc add dev $i root netem delay 10ms rate 100mbit; done
echo "topology up"
