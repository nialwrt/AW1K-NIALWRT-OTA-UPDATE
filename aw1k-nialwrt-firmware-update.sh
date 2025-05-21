#!/bin/sh

SCRIPT_URL="https://raw.githubusercontent.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/refs/heads/main/aw1k-nialwrt-firmware-update.sh"
LOCAL_SCRIPT="/usr/bin/update"
TMP_SCRIPT="/tmp/update.tmp"

wget -q -O "$TMP_SCRIPT" "$SCRIPT_URL"
if [ $? -eq 0 ]; then
  if ! cmp -s "$LOCAL_SCRIPT" "$TMP_SCRIPT"; then
    echo "UPDATE FOUND. UPDATING SCRIPT..."
    cp "$TMP_SCRIPT" "$LOCAL_SCRIPT"
    chmod +x "$LOCAL_SCRIPT"
    echo "UPDATED SCRIPT. RESTARTING..."
    exec "$LOCAL_SCRIPT" "$@"
    exit 0
  fi
fi

clear
echo "#############################"
echo "AW1K NIALWRT FIRMWARE UPDATE"
echo "#############################"
echo "1) NIALWRT 24.10.1"
echo "2) NEVERMORESSH"
echo "3) QWRT V1"
echo "#############################"
printf "ENTER YOUR CHOICE [1-3]: "
read CHOICE

case "$CHOICE" in
  1) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/NIALWRT-24.10.1.bin" ;;
  2) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/NEVERMORESSH.bin" ;;
  3) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/QWRT-V1.bin" ;;
  *) echo "CANCELLED."; exit 0 ;;
esac

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
