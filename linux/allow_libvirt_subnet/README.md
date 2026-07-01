# allow_libvirt_subnet

Let the local **libvirt** VM bridge (`virbr0`) through a restrictive always-on
**nftables** firewall.

## The problem

Some always-on firewalls — certain VPN / ZTNA clients, or hardened host setups —
install an nftables table with a **default-`drop`** policy on the `input` and
`output` hooks, allowing only an explicit set of endpoints. On such a host a libvirt
NAT network silently breaks: the guest's DHCP request on `virbr0` is dropped, so the
VM boots fine but **never gets an IP** (`virsh net-dhcp-leases default` stays empty).

You can confirm this is the cause with:

```bash
sudo nft list ruleset | grep -iE 'hook input|policy drop|virbr'
```

If you see a base chain with `type filter hook input … policy drop` that doesn't
accept `virbr0`, that's the culprit.

## What this does

It finds the base chain(s) enforcing the drop and inserts a **local-only** accept for
the libvirt bridge. It permits traffic only on the local virtual bridge between the
host and its VMs — it does **not** bypass the firewall for internet/real traffic and
does **not** expose the host externally.

## Usage

```bash
sudo ./allow_libvirt_subnet.sh                  # auto-detect drop chains, allow virbr0
sudo ./allow_libvirt_subnet.sh --bridge virbr1  # target a different bridge
sudo ./allow_libvirt_subnet.sh --remove         # remove the rules this added
```

## Note

Firewalls like this are usually managed by a daemon that **rewrites the ruleset on
reconnect or policy refresh**, which will drop these rules again. Just re-run the
script when a VM loses connectivity. For a permanent fix, allow the libvirt subnet
(e.g. `192.168.122.0/24`) in the firewall's own configuration / policy instead.
