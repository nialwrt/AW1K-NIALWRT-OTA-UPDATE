AW1K NIALWRT FIRMWARE UPDATE

Automated firmware updater for Arcadyan AW1000 (AW1K) using OpenWrt/ImmortalWrt-based images.

This script allows you to easily download and flash a prebuilt firmware image for your AW1K router. It's designed to be simple and direct — suitable for CLI users who want to switch between builds without manually handling firmware files.

Features

Menu-driven firmware selection

Auto-download firmware from GitHub Releases

One-click flashing via sysupgrade -n (no config retained)


Disclaimer

Use at your own risk.

Make sure the selected firmware is compatible with your device (Arcadyan AW1000).

Flashing incorrect firmware may brick your device.



---

```bash
wget -qO /tmp/fw.sh https://raw.githubusercontent.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/main/aw1k-nialwrt-firmware-update.sh && chmod +x /tmp/fw.sh && /tmp/fw.sh
