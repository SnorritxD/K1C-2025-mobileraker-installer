#!/bin/sh
# Mobileraker Companion Installer for Creality K1C (2025 Model)

set -e

echo "================================================="
echo " Mobileraker Companion Installer - K1C (2025)   "
echo "================================================="

REPO_DIR="/usr/data/mobileraker_companion"
ENV_DIR="/usr/data/mobileraker-env"
CONFIG_DIR="/usr/data/printer_data/config"
LOG_DIR="/usr/data/printer_data/logs"
INIT_DIR="/opt/etc/init.d"
INIT_SCRIPT="$INIT_DIR/S98mobileraker"
CONF_FILE="$CONFIG_DIR/mobileraker.conf"
MOONRAKER_CONF="$CONFIG_DIR/moonraker.conf"
REPO_URL="https://github.com/Clon1998/mobileraker_companion.git"

# 1. Create directory structure on persistent storage
echo "[1/6] Creating directories in /usr/data/..."
mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$INIT_DIR"

# 2. Clone repository
if [ ! -d "$REPO_DIR" ]; then
    echo "[2/6] Cloning Mobileraker repository..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "[2/6] Repository already exists at $REPO_DIR."
fi

# 3. Create Python Virtual Environment (with safe fallback & build tools)
if [ ! -d "$ENV_DIR" ]; then
    echo "[3/6] Setting up Python Virtual Environment..."
    
    # Check if we are on a MIPS architecture (like Creality K1 series)
    if [ "$(uname -m)" = "mips" ] || [[ "$(uname -m)" =~ mips ]]; then
        echo "    -------------------------------------------------"
        echo "    [!] MIPS-architectuur gedetecteerd (K1-serie)."
        echo "    [!] Het compileren van Python-pakketten (zoals Pillow)"
        echo "    [!] vanaf de broncode kan 10 tot 15 minuten duren."
        echo "    [!] Het script is NIET vastgelopen, even geduld..."
        echo "    -------------------------------------------------"
    fi

    python3 -m venv "$ENV_DIR" 2>/dev/null || {
        echo "    Built-in venv not found. Installing virtualenv package..."
        python3 -m pip install --no-cache-dir virtualenv
        python3 -m virtualenv "$ENV_DIR"
    }

    echo "      Installing build tools and dependencies..."
    "$ENV_DIR/bin/pip" install --no-cache-dir --upgrade pip setuptools wheel pybind11
    
    if [ -f "$REPO_DIR/scripts/mobileraker-requirements.txt" ]; then
        "$ENV_DIR/bin/pip" install --no-cache-dir --no-build-isolation -r "$REPO_DIR/scripts/mobileraker-requirements.txt"
    elif [ -f "$REPO_DIR/requirements.txt" ]; then
        "$ENV_DIR/bin/pip" install --no-cache-dir --no-build-isolation -r "$REPO_DIR/requirements.txt"
    fi
else
    echo "[3/6] Virtual Environment already exists at $ENV_DIR."
fi

# 4. Create mobileraker.conf in Fluidd config directory
if [ ! -f "$CONF_FILE" ]; then
    echo "[4/6] Creating mobileraker.conf for Fluidd/Mainsail..."
    cat << 'EOF' > "$CONF_FILE"
[main]
config_version = 1

[printer default]
moonraker_uri = ws://127.0.0.1:7125/websocket
moonraker_api_key = False
EOF
else
    echo "[4/6] mobileraker.conf already exists."
fi

# 5. Create persistent startup script in /opt/etc/init.d/
echo "[5/6] Writing startup script to $INIT_SCRIPT..."
cat << 'EOF' > "$INIT_SCRIPT"
#!/bin/sh

case "$1" in
  start)
    echo "Starting Mobileraker Companion..."
    /usr/data/mobileraker-env/bin/python /usr/data/mobileraker_companion/mobileraker.py -c /usr/data/printer_data/config/mobileraker.conf > /usr/data/printer_data/logs/mobileraker.log 2>&1 &
    ;;
  stop)
    echo "Stopping Mobileraker Companion..."
    pkill -f mobileraker.py
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac
EOF

chmod +x "$INIT_SCRIPT"

# 6. Add Update Manager entry to moonraker.conf
if [ -f "$MOONRAKER_CONF" ]; then
    if ! grep -q "\[update_manager mobileraker\]" "$MOONRAKER_CONF"; then
        echo "[6/6] Adding Update Manager entry to moonraker.conf..."
        cat << 'EOF' >> "$MOONRAKER_CONF"

[update_manager mobileraker]
type: git_repo
path: /usr/data/mobileraker_companion
origin: https://github.com/Clon1998/mobileraker_companion.git
virtualenv: /usr/data/mobileraker-env
primary_branch: main
requirements: scripts/mobileraker-requirements.txt
install_script: scripts/install.sh
managed_services: mobileraker
EOF
    fi
fi

# Start service
echo "Starting Mobileraker Companion..."
"$INIT_SCRIPT" restart

sleep 2

# Verification
if ps | grep -v grep | grep -q "mobileraker.py"; then
    echo "================================================="
    echo " INSTALLATION SUCCESSFUL! (K1C 2025 Model)"
    echo " Mobileraker is running and editable via Fluidd."
    echo "================================================="
else
    echo "================================================="
    echo " WARNING: Service failed to start automatically."
    echo " Please check the log file: $LOG_DIR/mobileraker.log"
    echo "================================================="
fi
