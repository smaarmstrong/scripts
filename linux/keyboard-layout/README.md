# keyboard-layout

Quickly toggle between the **standard UK** keyboard layout (`gb`) and the
**UK International** layout (`gb-intl`).

Written for a **headless Rocky Linux** box (console-only, over SSH), but it also
works on a graphical Fedora/GNOME desktop — it detects where it's running and
uses the right mechanism automatically:

| Context | Mechanism |
|---------|-----------|
| Headless / text virtual console (the Rocky case) | `localectl` (needs root — handled via `sudo`) |
| X11 graphical session             | `setxkbmap` |
| GNOME / Wayland graphical session | `gsettings` (native Wayland) + `setxkbmap` for XWayland |

## Headless Rocky Linux notes

On a console-only server there's no display, so the graphical tools never run
(and usually aren't installed) — everything goes through `localectl`, which is
fine over SSH.

- **The effective setting is the console (VC) keymap** in `/etc/vconsole.conf`.
  `localectl set-x11-keymap` writes both the X11 layout and the derived VC
  keymap; a reboot isn't needed, but the physical console picks it up on the
  next login.
- **`xkeyboard-config` must be installed** for `localectl` to convert the XKB
  layout into a console keymap. On a minimal install: `sudo dnf install
  xkeyboard-config`. If it's missing, the script warns and falls back to setting
  the console keymap directly.
- **International on the console is approximate** — `kbd` ships a `uk` console
  keymap but no dedicated `gb-intl` one, so if the XKB conversion is unavailable
  the `intl` request falls back to plain `uk` (the script tells you when it does).

## Usage

From this directory:

```bash
make gb        # switch to the standard UK layout
make intl      # switch to the UK International layout
make toggle    # detect the current layout and switch to the other one
make status    # print the current keyboard layout
make help      # list targets
```

Or call the script directly (same subcommands):

```bash
bin/keyboard-layout status
bin/keyboard-layout toggle
```

## Install

Optional — put it on your `PATH` as `keyboard-layout`:

```bash
make install   # symlinks bin/keyboard-layout into ~/.local/bin
```

## How it works

`bin/keyboard-layout` is a single `bash` script (`set -euo pipefail`). Both
layouts map to XKB layout `gb`; the International layout just adds the `intl`
variant (`gb+intl` for gsettings, `gb pc105 intl` for `localectl`).

- **Detection** — `WAYLAND_DISPLAY` / `DISPLAY` decide graphical vs TTY, and
  `XDG_SESSION_TYPE` / `WAYLAND_DISPLAY` decide Wayland vs X11.
- **Reading the current layout** — from `gsettings`, `setxkbmap -query`, or
  `localectl status`, whichever fits the context. `toggle` reads this, then
  applies the opposite.
- **Applying** — Wayland sets the GNOME input source via `gsettings` (and also
  `setxkbmap` so XWayland apps follow); X11 uses `setxkbmap`; a TTY uses
  `localectl set-x11-keymap`, which sets both the X11 layout and the derived
  console keymap.

## Privileges

Only the **console** (`localectl`) path needs root. The script detects this and
re-invokes the command via `sudo`, prompting you once. The graphical paths
(`gsettings`, `setxkbmap`) run as your normal user — no `sudo`.

## Limitations

- The graphical change applies to the **current** session. `gsettings` persists
  it for your GNOME user; `setxkbmap` alone does not survive a session restart.
- `setxkbmap` on a Wayland session only affects XWayland apps — native Wayland
  apps follow `gsettings`, which is why the script sets both.
- Assumes the layout is `gb`. It's intentionally a two-layout toggle, not a
  general layout switcher.
- `localectl set-x11-keymap` maps the X11 variant to the closest console keymap;
  a dedicated `gb-intl` console keymap may not exist on every system, so the TTY
  International result can be approximate.

## Requirements

Standard utilities only, no external dependencies:

- **Headless Rocky Linux**: `bash`, `localectl` (from `systemd`, always present),
  and `xkeyboard-config` for the `intl` variant (`sudo dnf install
  xkeyboard-config` if missing).
- **Graphical desktop**: whichever of `gsettings` / `setxkbmap` your session
  uses (present on a default Fedora Workstation).
