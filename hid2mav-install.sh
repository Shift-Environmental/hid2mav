#!/bin/bash
set -euo pipefail

# === CONFIG ===
INSTALL_DIR="/opt/hid2mav"
VENV_DIR="$INSTALL_DIR/venv"
SERVICE_NAME="hid2mav.service"
PY_SCRIPT_NAME="hid2mav-service.py"
CONFIG_SCRIPT_NAME="hid2mav-configure.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/hid2mav.log"

GREEN="\033[1;32m"; RED="\033[1;31m"; YELLOW="\033[1;33m"; NC="\033[0m"

echo -e "${GREEN}[INFO] Installing HID2MAV...${NC}"

# === Check files ===
if [[ ! -f "$SCRIPT_DIR/$PY_SCRIPT_NAME" ]]; then
  echo -e "${RED}[ERR] Cannot find $PY_SCRIPT_NAME in $SCRIPT_DIR${NC}"
  exit 1
fi
if [[ ! -f "$SCRIPT_DIR/$CONFIG_SCRIPT_NAME" ]]; then
  echo -e "${RED}[ERR] Missing $CONFIG_SCRIPT_NAME for configuration${NC}"
  exit 1
fi

# === Install system dependencies ===
echo -e "${GREEN}[INFO] Installing system packages...${NC}"
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip joystick

# === Copy files ===
echo -e "${GREEN}[INFO] Copying files to $INSTALL_DIR...${NC}"
sudo mkdir -p "$INSTALL_DIR"
sudo cp "$SCRIPT_DIR/$PY_SCRIPT_NAME" "$INSTALL_DIR"
sudo chown -R "$USER:$USER" "$INSTALL_DIR"

# === Create log file ===
echo -e "${GREEN}[INFO] Creating log file...${NC}"
sudo touch "$LOG_FILE"
sudo chown "$USER:$USER" "$LOG_FILE"

# === Setup virtualenv ===
echo -e "${GREEN}[INFO] Creating Python virtual environment...${NC}"
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install pymavlink inputs

# === Call configuration script ===
echo -e "${GREEN}[INFO] Running configuration...${NC}"
chmod +x "$SCRIPT_DIR/$CONFIG_SCRIPT_NAME"
"$SCRIPT_DIR/$CONFIG_SCRIPT_NAME"

echo -e "${GREEN}[OK] HID2MAV installed and configured.${NC}"
