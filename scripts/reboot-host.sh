#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <ssh-host>"
    exit 1
fi

SSH_HOST="$1"

PENDING=$(ssh "$SSH_HOST" "readlink -f /nix/var/nix/profiles/system")
echo "Pending generation: $PENDING"
echo "Rebooting $SSH_HOST..."
ssh "$SSH_HOST" "sudo systemctl reboot" 2>/dev/null || true
echo "Waiting for $SSH_HOST to come back..."
sleep 10
for i in $(seq 1 30); do
    ssh -o ConnectTimeout=5 "$SSH_HOST" "echo ok" 2>/dev/null && break
    echo "  waiting... ($i/30)"
    sleep 5
done
echo "$SSH_HOST is back!"
ACTIVE=$(ssh "$SSH_HOST" "readlink /run/current-system")
if [ "$PENDING" = "$ACTIVE" ]; then
    echo "✓ Boot successful: $ACTIVE"
else
    echo "⚠  Booted into unexpected generation"
    echo "  Expected: $PENDING"
    echo "  Active:   $ACTIVE"
fi
