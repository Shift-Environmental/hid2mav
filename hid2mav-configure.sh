#!/bin/bash
set -euo pipefail

SERVICE_NAME="hid2mav.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

INSTALL_DIR="/opt/hid2mav"
VENV_DIR="$INSTALL_DIR/venv"
PY_SCRIPT_NAME="hid2mav-service.py"

GREEN="\033[1;32m"; RED="\033[1;31m"; YELLOW="\033[1;33m"; NC="\033[0m"

echo -e "${GREEN}[INFO] Reconfiguring HID2MAV systemd service...${NC}"

# === MAVLink Endpoint ===
read -rp "Enter MAVLink endpoint (e.g., tcp:192.168.168.1:5760): " SERIAL_PATH
if [[ -z "$SERIAL_PATH" ]]; then
  echo -e "${RED}[ERR] MAVLink endpoint required.${NC}"
  exit 1
fi

# === Joystick Selection ===
HID_DEVS=($(ls /dev/input/js* 2>/dev/null || true))
if [[ ${#HID_DEVS[@]} -eq 0 ]]; then
  read -rp "Enter HID device manually (e.g., /dev/input/js0): " HID_PATH
else
  i=1; for dev in "${HID_DEVS[@]}"; do
    NAME=$(cat /sys/class/input/"$(basename "$dev")"/device/name 2>/dev/null || echo "Unknown")
    echo "  [$i] $dev — $NAME"
    ((i++))
  done
  read -rp "Select HID device by number: " SEL
  if ! [[ "$SEL" =~ ^[0-9]+$ ]] || (( SEL < 1 || SEL > ${#HID_DEVS[@]} )); then
    echo -e "${RED}[ERR] Invalid selection.${NC}"
    exit 1
  fi
  HID_PATH="${HID_DEVS[$((SEL-1))]}"
fi

# === Timing Values ===
read -rp "Enter HEARTBEAT interval in ms (100–1000): " HB_MS
if ! [[ "$HB_MS" =~ ^[0-9]+$ ]] || (( HB_MS < 100 || HB_MS > 1000 )); then
  echo -e "${RED}[ERR] Invalid heartbeat interval.${NC}"
  exit 1
fi

read -rp "Enter MANUAL_CONTROL interval in ms (100–1000): " MC_MS
if ! [[ "$MC_MS" =~ ^[0-9]+$ ]] || (( MC_MS < 100 || MC_MS > 1000 )); then
  echo -e "${RED}[ERR] Invalid manual control interval.${NC}"
  exit 1
fi

# === Overwrite systemd service ===
echo -e "${GREEN}[INFO] Updating $SERVICE_FILE...${NC}"
cat <<EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=HID to MAVLink bridge
After=network.target

[Service]
Environment="HEARTBEAT_INTERVAL_MS=$HB_MS"
Environment="MANUAL_CONTROL_INTERVAL_MS=$MC_MS"
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/$PY_SCRIPT_NAME --serial $SERIAL_PATH --hid $HID_PATH
WorkingDirectory=$INSTALL_DIR
Restart=on-failure
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# === Reload and restart ===
sudo systemctl daemon-reload
sudo systemctl restart "$SERVICE_NAME"

echo -e "${GREEN}[OK] HID2MAV service updated and restarted.${NC}"
echo -e "${GREEN}[INFO] Heartbeat: ${HB_MS} ms | Manual Control: ${MC_MS} ms${NC}"
