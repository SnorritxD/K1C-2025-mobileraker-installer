 <div align="center">

# 🖨️ K1C (2025) Mobileraker Companion Installer

**Mobileraker Companion installer for the rooted Creality K1C (2025).**

MIPS-aware dependency handling · Persistent storage · Startup script · Moonraker Update Manager integration

[Mobileraker Companion](https://github.com/Clon1998/mobileraker_companion) · [Installation](#-installation) · [Uninstall](#-uninstall)

![Platform](https://img.shields.io/badge/Platform-Creality%20K1C%202025-blue)
![Architecture](https://img.shields.io/badge/Architecture-MIPS-orange)
![Shell](https://img.shields.io/badge/Shell-POSIX-lightgrey)

</div>

---

## ✨ Features

* 💾 **Persistent storage:** stores the Companion repository, Python virtual environment, configuration, and log under `/usr/data`.
* 🐍 **Python environment:** creates a virtual environment if one does not already exist.
* 🧩 **MIPS-specific handling:** attempts to install Entware dependencies and prepare Pillow for MIPS systems.
* ⚙️ **Configuration:** creates a default `mobileraker.conf` only when the file does not already exist.
* 🚀 **Startup script:** creates `/opt/etc/init.d/S98mobileraker` with `start`, `stop`, and `restart` commands.
* 🔄 **Moonraker Update Manager:** adds an update-manager section when `moonraker.conf` exists and the section is not already present.
* 📝 **Logging:** redirects Companion output to `/usr/data/printer_data/logs/mobileraker.log`.

> **Target platform:** developed and tested on a rooted Creality K1C (2025 model). Compatibility with other models and firmware versions is not claimed.

## 🚀 Installation

Connect to your rooted K1C over SSH as `root` and run:

```sh
wget --no-check-certificate -qO- https://raw.githubusercontent.com/SnorritxD/K1C-2025-mobileraker-installer/refs/heads/main/install.sh | sh
```

The script prepares the directories, clones the official Mobileraker Companion repository if it is missing, attempts to prepare the Python environment and dependencies, writes the configuration and startup script, and attempts to start the Companion.

**Security note:** this command downloads and executes a shell script. Review the script before running it if you want to inspect exactly what it will do.

## 🛠️ Installation process

The installer performs the following steps:

1. Creates the configuration, log, and init-script directories.
2. Clones `https://github.com/Clon1998/mobileraker_companion.git` into `/usr/data/mobileraker_companion` if that directory does not already exist.
3. Creates `/usr/data/mobileraker-env` if the virtual environment does not already exist.
4. On MIPS systems, attempts to install `gcc`, `make`, `python3-dev`, `libjpeg`, `zlib`, and `python3-pillow` through Entware when `opkg` is available.
5. Upgrades `pip`, `setuptools`, `wheel`, and `pybind11` in the virtual environment.
6. Attempts to copy precompiled Pillow-related files from `/opt/lib` into the virtual environment.
7. Installs dependencies from `scripts/mobileraker-requirements.txt`, or falls back to `requirements.txt`, filtering out lines containing `pillow`.
8. Creates `mobileraker.conf` if it does not already exist.
9. Writes the executable startup script `/opt/etc/init.d/S98mobileraker`.
10. Adds a Moonraker Update Manager entry if `moonraker.conf` exists and does not already contain `[update_manager mobileraker]`.
11. Attempts to restart the Companion and checks the process list after a three-second delay.

### Important behavior

Some dependency-installation commands are deliberately allowed to fail without terminating the installer. Therefore, reaching the end of the script does not by itself guarantee that every dependency installed successfully.

If neither supported requirements file exists, the script skips that requirements-installation step.

Existing repository directories and virtual environments are reused rather than automatically rebuilt or updated.

## 📂 Installation paths

| Component                  | Path                                             |
| -------------------------- | ------------------------------------------------ |
| Companion repository       | `/usr/data/mobileraker_companion`                |
| Python virtual environment | `/usr/data/mobileraker-env`                      |
| Companion configuration    | `/usr/data/printer_data/config/mobileraker.conf` |
| Log file                   | `/usr/data/printer_data/logs/mobileraker.log`    |
| Startup script             | `/opt/etc/init.d/S98mobileraker`                 |
| Moonraker configuration    | `/usr/data/printer_data/config/moonraker.conf`   |

## ⚙️ Default configuration

If `mobileraker.conf` does not exist, the installer creates it with these settings:

```ini
[main]
config_version = 1

[printer default]
moonraker_uri = ws://127.0.0.1:7125/websocket
moonraker_api_key = False
```

If the file already exists, the installer leaves it unchanged.

## 🚀 Startup and service management

The installer creates `/opt/etc/init.d/S98mobileraker`. The script supports these commands:

**Start**

```sh
/opt/etc/init.d/S98mobileraker start
```

**Stop**

```sh
/opt/etc/init.d/S98mobileraker stop
```

**Restart**

```sh
/opt/etc/init.d/S98mobileraker restart
```

The `start` command launches `mobileraker.py` using the virtual environment's Python interpreter and redirects output to the log file.

The `stop` command searches the process list for `mobileraker.py` and attempts to terminate matching processes. The `restart` command stops the process, waits one second, and starts it again.

The installer calls `restart` at the end of installation. Automatic execution on every subsequent reboot depends on the printer's init system invoking scripts in `/opt/etc/init.d/`. The installer does not separately configure a boot hook.

## 🔄 Moonraker Update Manager

When `/usr/data/printer_data/config/moonraker.conf` exists and does not already contain `[update_manager mobileraker]`, the installer appends:

```ini
[update_manager mobileraker]
type: git_repo
path: /usr/data/mobileraker_companion
origin: https://github.com/Clon1998/mobileraker_companion.git
virtualenv: /usr/data/mobileraker-env
primary_branch: main
requirements: scripts/mobileraker-requirements.txt
install_script: scripts/install.sh
```

The installer does not create `moonraker.conf` if it is missing. If the section already exists, it does not update or validate that section.

## 📝 Logs and troubleshooting

The Companion log is stored at:

`/usr/data/printer_data/logs/mobileraker.log`

View it over SSH:

```sh
cat /usr/data/printer_data/logs/mobileraker.log
```

The installer waits three seconds after attempting to restart the service and searches the process list for `mobileraker`. It prints a success or warning message based on that check. This process check is a basic startup check, not a complete health test of the Companion.

## 🗑️ Uninstall

Stop the service:

```sh
/opt/etc/init.d/S98mobileraker stop
```

Remove the application repository, virtual environment, and startup script:

```sh
rm -rf /usr/data/mobileraker_companion \
       /usr/data/mobileraker-env \
       /opt/etc/init.d/S98mobileraker
```

### Optional configuration cleanup

The removal commands above do not remove configuration files, logs, Entware packages, or the Update Manager section.

If you also want to remove the Companion configuration and log, run:

```sh
rm -f /usr/data/printer_data/config/mobileraker.conf \
      /usr/data/printer_data/logs/mobileraker.log
```

If `[update_manager mobileraker]` exists in `moonraker.conf`, remove that section manually while preserving other Moonraker configuration entries.

**Warning:** check each path before deleting files. These commands permanently remove the specified files and directories.

## ⚠️ Disclaimer

This project is provided **"as is"**, without warranty of any kind, express or implied. Installing third-party software on a rooted printer involves risk. The author is not responsible for damage, data loss, or system issues resulting from the use of this installer.

---

<div align="center">

**Made for the Creality K1C (2025) community** 🧡

</div>
