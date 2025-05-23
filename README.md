[![Status](https://img.shields.io/badge/Status-Stable-green.svg)](https://github.com/nialwrt/UNIVERSAL-NIALWRT)
[![License](https://img.shields.io/badge/License-GPLv2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)](https://github.com/nialwrt/UNIVERSAL-NIALWRT)

# AW1K NIALWRT OTA UPDATE

## Overview

**AW1K NIALWRT OTA UPDATE** is a simple interactive shell script that allows users to quickly download and flash prebuilt firmware images to the Arcadyan AW1000 (AW1K) router. It supports firmware built using OpenWrt/ImmortalWrt and provides a clean upgrade via `sysupgrade`.

## Features

- **Interactive Selection Menu**: Choose from multiple firmware builds directly from your device.
- **Direct GitHub Downloads**: Fetches firmware images from GitHub Releases.
- **Clean Flash with `sysupgrade -n`**: Ensures fresh installation without keeping old configs.

## Requirements

- Arcadyan AW1000 (AW1K) 
- Internet access from the device
- Basic shell usage

## Quick Installation

Run this command directly on your OpenWrt/ImmortalWrt terminal:

```sh
wget -qO /tmp/update.tmp https://raw.githubusercontent.com/nialwrt/AW1K-NIALWRT-OTA-UPDATE/refs/heads/main/aw1k-nialwrt-ota-update.sh && chmod +x /tmp/update.tmp && //tmp/update.tmp
