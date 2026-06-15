# Mullscaled

An nftables ruleset that lets Tailscale work alongside Mullvad VPN without using the [official method](https://tailscale.com/docs/features/exit-nodes/mullvad-exit-nodes).

## The Problem

Mullvad's kill switch blocks all non-tunnel traffic, including Tailscale's
CGNAT range (`100.64.0.0/10`) which makes it impossible to contact devices over your tailnet.

## The Solution

Mark all Tailscale-bound packets with Mullvad's own internal marks
(`ct mark 0x00000f41` and `meta mark 0x6d6f6c65`). This tricks Mullvad's
routing and firewall rules into treating Tailscale traffic as if it were
already inside the VPN tunnel, so it is allowed to exit via `tailscale0`.

## Prerequisites

- systemd-resolved managing DNS
- nftables (not iptables)
- NetworkManager
- Both Mullvad and Tailscale installed

## Addresses Used

These are universal Tailscale addresses, not user-specific:

| Address                 | Purpose                           |
| ----------------------- | --------------------------------- |
| `100.64.0.0/10`         | Tailscale IPv4 mesh network       |
| `100.100.100.100`       | Tailscale MagicDNS resolver       |
| `fd7a:115c:a1e0::/48`   | Tailscale IPv6 range              |
| `199.247.155.53`        | Tailscale public `ts.net` DNS (v4) |
| `2620:111:8007::53`     | Tailscale public `ts.net` DNS (v6) |

The public `ts.net` resolvers are used for non-tailnet `.ts.net` domains (e.g. Mullvad exit-nodes published under `*.mullvad.ts.net`). Mullvad's kill switch blocks all outbound port-53 traffic except to its own tunnel DNS, so these must also be marked or Tailscale will raise a `dns-forward-failing` health warning after the first blocked query.

## Installation

```bash
sudo ./install.sh
```

The installer loads the nftables rules into the running kernel and enables
a systemd oneshot service so they are reapplied on boot.

Tested on Arch Linux with Mullvad VPN 2026.2 and Tailscale 1.98.4

## Why not use the official method?

Using Tailscale with Mullvad as an exit node requires purchasing
Mullvad through Tailscale. This defeats the complete privacy that Mullvad
enables with their anonymous payment model.

Or maybe you already have prepaid for 12 months of Mullvad, and you don't want to buy it through Tailscale in addition
