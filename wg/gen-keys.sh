#!/bin/bash
# Generates one keypair per node into keys/ (git-ignored).
cd "$(dirname "$0")/../keys"
umask 077
for n in gwa gwb ra; do
  [ -f $n.key ] || wg genkey | tee $n.key | wg pubkey > $n.pub
done
echo "keys in $(pwd)"
