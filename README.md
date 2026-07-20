# scripts

A grab-bag of personal automation scripts, grouped by platform / domain.

## linux/

| Script | What it does |
|--------|--------------|
| [ollama](linux/ollama/) | Install Ollama + an offline language tutor (reading, grammar drills) |
| [keyboard-layout](linux/keyboard-layout/) | Toggle UK (`gb`) ⇄ UK International (`gb-intl`); headless-Rocky/console-first, also X11/Wayland |
| [wifi_connect](linux/wifi_connect/) | Connect to Wi-Fi from the CLI via `nmcli` |
| [allow_libvirt_subnet](linux/allow_libvirt_subnet/) | Let the libvirt VM bridge through a default-drop nftables firewall |
| [kill_postgres.zsh](linux/kill_postgres.zsh) | Kill all `postgres`-owned processes |

## macos/

| Script | What it does |
|--------|--------------|
| [change_host_name](macos/change_host_name/) | Set (or randomise) the machine hostname via `scutil` |
| [spoof_mac](macos/spoof_mac/) | Spoof the `en0` MAC address to get past a blacklist |

## frameworks/

| Script | What it does |
|--------|--------------|
| [django](frameworks/django/) | GitHub Actions CI workflow for Django |
| [react](frameworks/react/) | GitHub Actions CI workflow for React |
| [swiftui](frameworks/swiftui/) | SwiftLint pre-commit / CI workflow |
| [boilerplate](frameworks/boilerplate/) | Trim a fresh .NET Web API down to a minimal `Program.cs` |

## git/

| Script | What it does |
|--------|--------------|
| [token](git/token/) | Set an origin remote URL using a token from a `.env` file |
