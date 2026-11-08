#!/bin/bash
# Renders configs from templates + keys, then brings WireGuard up. Run as root.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$ROOT/keys/gwa.key" ] || "$ROOT/wg/gen-keys.sh"
for n in gwa gwb ra; do
  mkdir -p "$ROOT/build/$n"
  sed -e "s#__PRIV__#$(cat "$ROOT/keys/$n.key")#" \
      -e "s#__PUB_GWA__#$(cat "$ROOT/keys/gwa.pub")#" \
      -e "s#__PUB_GWB__#$(cat "$ROOT/keys/gwb.pub")#" \
      -e "s#__PUB_RA__#$(cat "$ROOT/keys/ra.pub")#" \
      "$ROOT/wg/$n.conf.tpl" > "$ROOT/build/$n/wg0.conf"
  chmod 600 "$ROOT/build/$n/wg0.conf"
  ip netns exec $n wg-quick up "$ROOT/build/$n/wg0.conf"
done
echo "WireGuard up. Try: ip netns exec ha ping -c2 10.2.0.10"
