#!/bin/bash
for n in ha gwa rinet gwb hb ra; do ip netns del $n 2>/dev/null; done
echo "topology removed"
