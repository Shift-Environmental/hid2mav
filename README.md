# HID2MAV

A lightweight Linux-based system for turning HID joysticks into MAVLink MANUAL_CONTROL

## Components

-  `hid2mav-service.py` — main Python service (runs as a systemd unit)
-  `hid2mav-install.sh` — installs Python dependencies, sets up the systemd service
-  `hid2mav-configure.sh` — reconfigures serial/HID device selection and updates the service
-  `hid2mav-status.sh` — prints service status and last logs
-  `hid2mav-test.py` — live joystick monitor (GUI by default, falls back to console)

## Requirements

-  Python 3
-  Linux (Debian-based recommended)
-  Joystick or gamepad connected via `/dev/input/js*`
-  IP-based MAVLink endpoint (e.g., `tcp:192.168.168.1:5760`)

## Installation

```bash
chmod +x hid2mav-install.sh
./hid2mav-install.sh
```
