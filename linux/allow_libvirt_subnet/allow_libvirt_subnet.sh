#!/usr/bin/env bash
#
# allow_libvirt_subnet.sh — let the local libvirt VM bridge through a restrictive
# always-on nftables firewall, so libvirt guests can get DHCP and be reached.
#
# WHY: some always-on firewalls (certain VPN / ZTNA clients, hardened hosts) install
# an nftables table with a default-DROP policy on the input and output hooks,
# permitting only an explicit set of endpoints. On such a host a libvirt NAT network
# silently breaks — the guest's DHCP request on the bridge is dropped and the VM
# never gets an IP.
#
# This finds the base chain(s) enforcing that drop and inserts a LOCAL-ONLY accept
# for the libvirt bridge. It permits traffic only on the local virtual bridge between
# the host and its VMs: it does NOT bypass the firewall for internet/real traffic and
# does NOT expose the host externally.
#
# Firewalls like this are often managed by a daemon that rewrites the ruleset on
# reconnect/refresh, so re-run this if a VM loses connectivity. Undo with --remove
# (or restart/reconnect the managing service).
#
# Usage:
#   sudo ./allow_libvirt_subnet.sh                  # auto-detect drop chains, allow virbr0
#   sudo ./allow_libvirt_subnet.sh --bridge virbr1  # target a different bridge
#   sudo ./allow_libvirt_subnet.sh --remove         # remove the rules this added
#
set -euo pipefail

BRIDGE="virbr0"
MODE="add"
while [ $# -gt 0 ]; do
  case "$1" in
    --bridge) BRIDGE="$2"; shift 2 ;;
    --remove) MODE="remove"; shift ;;
    -h|--help) sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $1 (try --help)" >&2; exit 1 ;;
  esac
done

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }
command -v nft >/dev/null || { echo "nft (nftables) not found." >&2; exit 1; }

# Discover base chains enforcing a default-drop on the input/output hooks.
# Emits lines: "<family> <table> <chain> <hook>"
mapfile -t targets < <(
  nft -a list ruleset 2>/dev/null | awk '
    $1=="table"  { fam=$2; tbl=$3 }
    $1=="chain"  { ch=$2 }
    /hook input/  && /policy drop/ { print fam, tbl, ch, "input" }
    /hook output/ && /policy drop/ { print fam, tbl, ch, "output" }
  '
)

if [ "${#targets[@]}" -eq 0 ]; then
  echo "No default-drop input/output firewall chains found — nothing to do."
  echo "(If your VM still has no network, the block is elsewhere.)"
  exit 0
fi

rule_expr() {  # $1 = hook
  if [ "$1" = "input" ]; then echo "iif \"$BRIDGE\" accept"; else echo "oif \"$BRIDGE\" accept"; fi
}

for t in "${targets[@]}"; do
  read -r fam tbl ch hook <<<"$t"
  expr="$(rule_expr "$hook")"

  if [ "$MODE" = "remove" ]; then
    nft -a list chain "$fam" "$tbl" "$ch" 2>/dev/null \
      | grep -- "$expr" | grep -oE 'handle [0-9]+' | awk '{print $2}' \
      | while read -r h; do nft delete rule "$fam" "$tbl" "$ch" handle "$h"; done
    echo "removed: $fam $tbl $ch ($hook) $BRIDGE"
  else
    if nft list chain "$fam" "$tbl" "$ch" 2>/dev/null | grep -q -- "$expr"; then
      echo "already present: $fam $tbl $ch ($hook)"
    else
      # shellcheck disable=SC2086
      eval nft insert rule "$fam" "$tbl" "$ch" $expr
      echo "allowed $BRIDGE on: $fam $tbl $ch ($hook)"
    fi
  fi
done

[ "$MODE" = "add" ] && echo "Done. libvirt guests on $BRIDGE should now be able to get an IP."
exit 0
