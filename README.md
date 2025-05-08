# HID2MAV

A lightweight Linux-based system for turning HID joysticks into MAVLink `MANUAL_CONTROL` messages over an IP-based telemetry link.

## Components

-  `hid2mav-service.py` — Main Python service that transmits `MANUAL_CONTROL` and `HEARTBEAT` messages via MAVLink
-  `hid2mav-install.sh` — Installs dependencies, copies files, and calls the configuration script
-  `hid2mav-configure.sh` — Interactively sets:
   -  MAVLink endpoint (e.g., `tcp:192.168.168.1:5760`)
   -  HID device path (e.g., `/dev/input/js0`)
   -  Heartbeat interval (100–1000 ms)
   -  Manual control interval (100–1000 ms)
-  `hid2mav-status.sh` — Shows systemd status, ExecStart config, and last 10 logs
-  `hid2mav-uninstall.sh` — Cleanly removes the service, files, and optionally the log
-  `hid2mav-test.py` — Standalone joystick monitor (GUI by default, console fallback)

## Requirements

-  Linux (Debian-based recommended)
-  Python 3
-  Joystick or gamepad accessible via `/dev/input/js*`
-  IP-based MAVLink-compatible endpoint (e.g., `tcp:192.168.168.1:5760`)
-  ArduPilot with `FS_GCS_ENABLE = 1` and `FS_GCS_TIMEOUT` configured as needed

## Installation

```bash
chmod +x hid2mav-install.sh
./hid2mav-install.sh
```

This will:

-  Install required system and Python packages
-  Set up a virtual environment in `/opt/hid2mav`
-  Prompt for your joystick and MAVLink configuration
-  Create and start the `hid2mav.service` systemd unit

## Reconfigure Settings

You can rerun the configuration any time:

```bash
./hid2mav-configure.sh
```

## Monitor Status

```bash
./hid2mav-status.sh
```

Shows service state, command config, and last 10 logs via `journalctl`.

## Uninstall

```bash
./hid2mav-uninstall.sh
```

Stops and disables the service, deletes installed files, and lets you optionally remove logs.

## Notes

-  The systemd service passes heartbeat and control intervals via environment variables.
-  Ensure your flight controller is in a mode that accepts `MANUAL_CONTROL` messages (e.g., STABILIZE).
