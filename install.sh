#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy nftables config
cp "$SCRIPT_DIR/mullscaled.nft" /etc/nftables-mullscaled.nft
chmod 644 /etc/nftables-mullscaled.nft

# Install systemd service
cp "$SCRIPT_DIR/mullscaled.service" /etc/systemd/system/mullscaled.service

# Enable and start
systemctl daemon-reload
systemctl enable mullscaled.service
systemctl restart mullscaled.service

echo "Mullscaled installed and started."
echo "Tailscale traffic is now excluded from Mullvad's kill switch."
