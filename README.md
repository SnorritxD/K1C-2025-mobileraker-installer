# K1C (2025 Model) Mobileraker Companion Installer

An automated, persistent installation script for Mobileraker Companion on a rooted Creality K1C (2025 Model), designed specifically for MIPS architecture compatibility and seamless Moonraker Update Manager integration.

## Features
💾 **100% Persistent:** Installs all files on the `/usr/data/` partition to ensure everything survives system reboots.

⚙️ **Fluidd & Mainsail Integration:** Places `mobileraker.conf` in `/usr/data/printer_data/config/` so you can manage settings directly from the web interface. 

🚀 **Automatic Startup:** Generates an init script at `/opt/etc/init.d/S98mobileraker` for background service execution on boot. 

🔄 **Update Manager Support & Clean Git State:** Integrates with Moonraker's Update Manager while utilizing a temporary requirements filter (`/tmp`) to prevent modifications to tracked files. This keeps your Git repository 100% clean and avoids annoying "dirty repo" or "INVALID" errors in Fluidd/Mainsail. 

## What Happens During Installation (Step-by-Step)
1. **Environment Setup:** Creates a dedicated Python virtual environment at `/usr/data/mobileraker-env`.
2. **Dependency Handling:** Automatically checks for MIPS-specific architecture constraints and filters out problematic packages like Pillow to prevent out-of-memory (OOM) errors or segmentation faults.
3. **Repository Cloning:** Clones the official or custom Mobileraker Companion repository into `/usr/data/mobileraker_companion`.
4. **Configuration Generation:** Sets up `mobileraker.conf` inside your Klipper config directory with default or tailored settings.
5. **Service Deployment:** Writes an executable init script to `/opt/etc/init.d/S98mobileraker` so the companion service starts automatically alongside Klipper and Moonraker.
6. **Moonraker Integration:** Appends the necessary `[update_manager mobileraker]` block to your `moonraker.conf` file.

## Important Note for Creality K1 / K1C (MIPS Architecture)
Because the K1 series runs on a MIPS architecture, standard pre-compiled binaries for certain Python dependencies are not natively available. The installation script handles these packages safely to ensure a smooth, error-free setup without destabilizing your printer's firmware.

## Installation (One-Line Command)
SSH into your rooted K1C as root and run the following command:

```bash
wget --no-check-certificate -qO- https://raw.githubusercontent.com/SnorritxD/K1C-2025-mobileraker-installer/refs/heads/main/install.sh | sh
```

## How to Uninstall / Undo Installation
If your internet connection drops during setup, or if you want to completely remove Mobileraker Companion and start fresh, run this cleanup command via SSH:

```bash
rm -rf /usr/data/mobileraker_companion \
       /usr/data/mobileraker-env \
       /opt/etc/init.d/S98mobileraker \
       /usr/data/printer_data/config/mobileraker.conf
```

This safely removes all installed files, virtual environments, and boot scripts without affecting your printer's core firmware or Klipper setup.

## Disclaimer
This script is provided "as is", without warranty of any kind, express or implied. Installing third-party software on a rooted 3D printer is done at your own risk. The author is not responsible for any damage, data loss, or system issues that may occur as a result of using this script.
