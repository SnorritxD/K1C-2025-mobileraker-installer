# **K1C (2025 Model) Mobileraker Companion Installer**

An automated, persistent installation script for **Mobileraker Companion** on a rooted Creality K1C (2025 Model).

**Features**
- 💾 **100% Persistent:** Installs all files on the `/usr/data/` partition to ensure everything survives system reboots.
- ⚙️ **Fluidd & Mainsail Integration:** Places `mobileraker.conf` in `/usr/data/printer_data/config/` so you can manage settings directly from the web interface.
- 🚀 **Automatic Startup:** Generates an init script at `/opt/etc/init.d/S98mobileraker` for background service execution on boot.
- 🔄 **Update Manager Support:** Adds Mobileraker to `moonraker.conf` so you can easily update it via Fluidd or Mainsail.

---

> **⚠️ Important Note for Creality K1 / K1C (MIPS Architecture)**
> Because the K1 series runs on a MIPS architecture, there are no pre-compiled wheels available for certain Python packages (such as `Pillow`). The installation script automatically compiles these packages from source. This can take **10 to 15 minutes**. It may temporarily look like the script or `pip` is stuck, but this is completely normal and the process is not frozen!

---

**Installation (One-Line Command)**

SSH into your rooted K1C as `root` and run the following command:

bash
wget --no-check-certificate -qO- https://raw.githubusercontent.com/SnorritxD/K1C-2025-mobileraker-installer/refs/heads/main/install.sh | sh

**How to Uninstall / Undo Installation**

If your internet connection drops during setup, or if you want to completely remove Mobileraker Companion and start fresh, run this cleanup command via SSH:

bash
rm -rf /usr/data/mobileraker_companion \
       /usr/data/mobileraker-env \
       /opt/etc/init.d/S98mobileraker \
       /usr/data/printer_data/config/mobileraker.conf

*This safely removes all installed files, virtual environments, and boot scripts without affecting your printer's firmware or Klipper setup.*

**Disclaimer**

This script is provided "as is", without warranty of any kind, express or implied. Installing third-party software on a rooted 3D printer is done at your own risk. The author is not responsible for any damage, data loss, or system issues that may occur as a result of using this script.
