#!/usr/bin/env bash
#
# wifi_connect.sh — connect to a Wi-Fi network from the CLI using NetworkManager.
#
# Set your network via environment variables (don't hardcode real creds here):
#
#   export WIFI_SSID="MyNetwork"
#   export WIFI_PASSWORD="supersecret"     # omit for an open network, or be prompted
#   ./wifi_connect.sh
#
# Or pass the SSID as an argument:  ./wifi_connect.sh "MyNetwork"
# If WIFI_PASSWORD isn't set, you'll be prompted (input hidden) rather than storing it.
#
# Subcommands:
#   ./wifi_connect.sh list        # scan and list nearby networks
#   ./wifi_connect.sh status      # show current Wi-Fi connection
#   ./wifi_connect.sh disconnect  # disconnect the Wi-Fi device
#
set -euo pipefail

WIFI_SSID="${WIFI_SSID:-}"
WIFI_PASSWORD="${WIFI_PASSWORD:-}"
WIFI_IFACE="${WIFI_IFACE:-}"   # optional, e.g. wlan0; auto-detected if empty

command -v nmcli >/dev/null || { echo "nmcli (NetworkManager) not found." >&2; exit 1; }

# Resolve the Wi-Fi interface (first wifi device) unless one was given.
wifi_iface() {
  [ -n "$WIFI_IFACE" ] && { echo "$WIFI_IFACE"; return; }
  nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}'
}

case "${1:-connect}" in
  list)
    nmcli radio wifi on
    nmcli device wifi rescan 2>/dev/null || true
    nmcli device wifi list
    exit 0
    ;;
  status)
    nmcli -f NAME,DEVICE,TYPE,STATE connection show --active | grep -iE 'wifi|wireless|NAME' || \
      echo "No active Wi-Fi connection."
    exit 0
    ;;
  disconnect)
    iface="$(wifi_iface)"
    [ -n "$iface" ] || { echo "No Wi-Fi device found." >&2; exit 1; }
    nmcli device disconnect "$iface"
    exit 0
    ;;
  *)
    # treat a non-subcommand argument as the SSID
    [ "${1:-connect}" != "connect" ] && WIFI_SSID="$1"
    ;;
esac

[ -n "$WIFI_SSID" ] || { echo "Set WIFI_SSID (or pass the SSID as an argument)." >&2; exit 1; }

# Prompt for the password if not provided (open networks: just press Enter).
if [ -z "$WIFI_PASSWORD" ]; then
  read -rs -p "Password for '$WIFI_SSID' (blank = open network): " WIFI_PASSWORD
  echo
fi

nmcli radio wifi on

iface="$(wifi_iface)"
ifname_args=()
[ -n "$iface" ] && ifname_args=(ifname "$iface")

echo "Connecting to '$WIFI_SSID'${iface:+ on $iface}..."
if [ -n "$WIFI_PASSWORD" ]; then
  nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASSWORD" "${ifname_args[@]}"
else
  nmcli device wifi connect "$WIFI_SSID" "${ifname_args[@]}"
fi

echo "Connected. Current status:"
nmcli -f NAME,DEVICE,STATE connection show --active | grep -iE "$WIFI_SSID|NAME" || true
