#!/bin/sh

SCRIPT_URL_ORIGINAL="https://raw.githubusercontent.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/refs/heads/main/aw1k-nialwrt-firmware-update.sh"
LOCAL_SCRIPT="/usr/bin/update"
TMP_SCRIPT="/tmp/update.tmp"

wget -q -O "$TMP_SCRIPT" "$SCRIPT_URL_ORIGINAL"
if [ $? -eq 0 ] && ! cmp -s "$LOCAL_SCRIPT" "$TMP_SCRIPT"; then
  echo "UPDATE FOUND. UPDATING SCRIPT..."
  cp "$TMP_SCRIPT" "$LOCAL_SCRIPT"
  chmod +x "$LOCAL_SCRIPT"
  echo "UPDATED SCRIPT. RESTARTING..."
  exec "$LOCAL_SCRIPT" "$@"
  exit 0
fi

clear
echo "#############################"
echo "AW1K NIALWRT FIRMWARE UPDATE"
echo "#############################"
echo "         FREEMIUM"
echo "1) NIALWRT 24.10.1"
echo "2) NEVERMORESSH"
echo "3) QWRT V1"
echo "#############################"
echo "         PREMIUM"
echo "4) NIALWRT 24.10.1 PRO V1"
echo "5) NIALWRT 24.10.1 PRO V2"
echo "#############################"
printf "ENTER YOUR CHOICE [1-5]: "
read CHOICE

URL=""
SCRIPT_URL=""

case "$CHOICE" in
  1) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/NIALWRT-24.10.1.bin" ;;
  2) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/NEVERMORESSH.bin" ;;
  3) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/QWRT-V1.bin" ;;
  4) SCRIPT_URL="http://abidarwi.sh/nialwrt11052025.sh" ;;
  5) SCRIPT_URL="http://abidarwi.sh/nialwrt22052025.sh" ;;
  *) echo "CANCELLED."; exit 0 ;;
esac

if [ "$CHOICE" = "4" ] || [ "$CHOICE" = "5" ]; then
  echo
  echo "DOWNLOADING INSTALLER SCRIPT FOR CHOICE $CHOICE..."
  wget -q -O /tmp/installer.sh "$SCRIPT_URL"
  if [ $? -ne 0 ]; then
    echo "ERROR: FAILED TO DOWNLOAD INSTALLER SCRIPT."
    exit 1
  fi
  chmod +x /tmp/installer.sh
  echo "RUNNING INSTALLER SCRIPT..."
  /tmp/installer.sh
  exit 0
fi

echo
echo "DOWNLOADING FIRMWARE FROM $URL ..."
wget -q -O /tmp/fwfile "$URL"
if [ $? -ne 0 ]; then
  echo "ERROR: FAILED TO DOWNLOAD FIRMWARE."
  exit 1
fi

printf "READY TO FLASH FIRMWARE? (Y/N): "
read CONFIRM
case "$CONFIRM" in
  y|Y)
    echo "FLASHING FIRMWARE ..."
    sysupgrade -n /tmp/fwfile
    ;;
  *)
    echo "FLASH CANCELLED."
    exit 0
    ;;
esac
