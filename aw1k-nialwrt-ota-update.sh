#!/bin/sh

rm -f /tmp/update.tmp /tmp/fwfile

SCRIPT_URL_ORIGINAL="https://raw.githubusercontent.com/nialwrt/AW1K-NIALWRT-OTA-UPDATE/refs/heads/main/aw1k-nialwrt-ota-update.sh"
LOCAL_SCRIPT="/usr/bin/update"
TMP_SCRIPT="/tmp/update.tmp"

wget -q -O "$TMP_SCRIPT" "$SCRIPT_URL_ORIGINAL"
if [ $? -eq 0 ] && ! cmp -s "$LOCAL_SCRIPT" "$TMP_SCRIPT"; then
  cp "$TMP_SCRIPT" "$LOCAL_SCRIPT"
  chmod +x "$LOCAL_SCRIPT"
  exec "$LOCAL_SCRIPT" "$@"
  exit 0
fi

clear
echo "####################################"
echo "      AW1K NIALWRT OTA UPDATE       "
echo "####################################"
echo "             FREEMIUM              "
echo " 1) IMMORTALWRT 24.10.1 LITE       "
echo " 2) OPENWRT 24.10.1 LITE           "
echo "####################################"
echo "             PREMIUM               "
echo " 3) IMMORTALWRT 24.10.1 PRO        "
echo " 4) OPENWRT 24.10.1 PRO            "
echo "####################################"
echo -n "SELECT OPTION: "
read CHOICE

URL=""
SCRIPT_URL=""
IS_PREMIUM=false

case "$CHOICE" in
  1)
    URL="https://github.com/nialwrt/AW1K-NIALWRT-OTA-UPDATE/releases/download/FIRMWARE/IMMORTALWRT-24.10.1-LITE.bin"
    ;;
  2)
    URL="-"
    ;;
  3)
    URL="https://github.com/nialwrt/AW1K-NIALWRT-OTA-UPDATE/releases/download/FIRMWARE/IMMORTALWRT-24.10.1-PRO.bin"
    ;;
  4)
    URL="-"
    ;;
  5)
    SCRIPT_URL="-"
    IS_PREMIUM=true
    ;;
  6)
    SCRIPT_URL="-"
    IS_PREMIUM=true
    ;;
esac

if [ "$IS_PREMIUM" = true ]; then
  wget -q -O /tmp/installer.sh "$SCRIPT_URL"
  if [ $? -ne 0 ]; then
    exit 1
  fi
  chmod +x /tmp/installer.sh
  /tmp/installer.sh
  exit 0
fi

echo "DOWNLOADING FIRMWARE..."
wget -q -O /tmp/fwfile "$URL"
if [ $? -ne 0 ]; then
  echo "ERROR: FAILED TO DOWNLOAD FIRMWARE."
  rm -f /tmp/fwfile /tmp/update.tmp
  exit 1
fi

echo -n "INSTALLING FIRMWARE? (Y/N):"
read CONFIRM
case "$CONFIRM" in
  y|Y)
    echo "FLASHING FIRMWARE ..."
    sysupgrade -n /tmp/fwfile
    ;;
  *)
    echo "FLASH CANCELLED."
    rm -f /tmp/fwfile /tmp/update.tmp
    exit 0
    ;;
esac
