# wifi_connect

Connect to a Wi-Fi network from the CLI using **NetworkManager** (`nmcli`) — handy on
headless / console-only machines (Fedora, RHEL, Rocky, etc.).

## Usage

Set your network via environment variables (keep real credentials out of the file):

```bash
export WIFI_SSID="MyNetwork"
export WIFI_PASSWORD="supersecret"   # omit for an open network, or be prompted
./wifi_connect.sh
```

Or pass the SSID as an argument (you'll be prompted for the password, input hidden):

```bash
./wifi_connect.sh "MyNetwork"
```

### Subcommands

```bash
./wifi_connect.sh list        # scan and list nearby networks
./wifi_connect.sh status      # show current Wi-Fi connection
./wifi_connect.sh disconnect  # disconnect the Wi-Fi device
```

## Notes

- The Wi-Fi interface is auto-detected (first `wifi` device). Override with
  `export WIFI_IFACE=wlan0` if needed.
- If `WIFI_PASSWORD` is unset, the script prompts for it with hidden input instead of
  storing it anywhere.
- Requires NetworkManager to be running (`systemctl status NetworkManager`).
