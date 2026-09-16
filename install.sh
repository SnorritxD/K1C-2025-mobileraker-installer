#!/bin/sh
# Mobileraker Companion Installer voor Creality K1C (2025 Model)

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

# 1. Mappenstructuur aanmaken op de permanente opslag
echo "[1/6] Mappen aanmaken op /usr/data/..."
mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$INIT_DIR"

# 2. Repository klonen
if [ ! -d "$REPO_DIR" ]; then
    echo "[2/6] Mobileraker repository klonen..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "[2/6] Repository bestaat al op $REPO_DIR."
fi

# 3. Python Virtual Environment aanmaken
if [ ! -d "$ENV_DIR" ]; then
    echo "[3/6] Python Virtual Environment opbouwen..."
    python3 -m venv "$ENV_DIR"
    echo "      Afhankelijkheden installeren..."
    if [ -f "$REPO_DIR/scripts/mobileraker-requirements.txt" ]; then
        "$ENV_DIR/bin/pip" install --no-cache-dir -r "$REPO_DIR/scripts/mobileraker-requirements.txt"
    elif [ -f "$REPO_DIR/requirements.txt" ]; then
        "$ENV_DIR/bin/pip" install --no-cache-dir -r "$REPO_DIR/requirements.txt"
    fi
else
    echo "[3/6] Virtual Environment bestaat al op $ENV_DIR."
fi

# 4. mobileraker.conf aanmaken in Fluidd config map
if [ ! -f "$CONF_FILE" ]; then
    echo "[4/6] mobileraker.conf aanmaken voor Fluidd/Mainsail..."
    cat << 'EOF' > "$CONF_FILE"
[main]
config_version = 1

[printer default]
moonraker_uri = ws://127.0.0.1:7125/websocket
moonraker_api_key = False
EOF
else
    echo "[4/6] mobileraker.conf bestaat al."
fi

# 5. Permanent opstartscript aanmaken op /opt/etc/init.d/
echo "[5/6] Opstartscript schrijven naar $INIT_SCRIPT..."
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

# 6. Update Manager toevoegen aan moonraker.conf
if [ -f "$MOONRAKER_CONF" ]; then
    if ! grep -q "\[update_manager mobileraker\]" "$MOONRAKER_CONF"; then
        echo "[6/6] Update Manager toevoegen aan moonraker.conf..."
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

# Service starten
echo "Mobileraker Companion starten..."
"$INIT_SCRIPT" restart

sleep 2

# Verificatie
if ps | grep -v grep | grep -q "mobileraker.py"; then
    echo "================================================="
    echo " INSTALLATIE GESLAAGD! (K1C 2025 Model)"
    echo " Mobileraker draait en is aanpasbaar via Fluidd."
    echo "================================================="
else
    echo "================================================="
    echo " WAARSCHUWING: Service kon niet automatisch starten."
    echo " Controleer de logfile: $LOG_DIR/mobileraker.log"
    echo "================================================="
fi
