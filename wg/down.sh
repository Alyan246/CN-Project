#!/bin/bash
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for n in gwa gwb ra; do
  ip netns exec $n wg-quick down "$ROOT/build/$n/wg0.conf" 2>/dev/null || true
done
