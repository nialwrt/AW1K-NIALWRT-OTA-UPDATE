#!/bin/sh
clear
echo "#############################"
echo "AW1K NIALWRT FIRMWARE UPDATE"
echo "#############################"
echo "1) IMMORTALWRT 24.10.1 FREE"
echo "2) NEVERMORESSH"
echo "3) QWRT V1"
echo "4) QWRT V2"
echo "#############################"
printf "ENTER YOUR CHOICE [1-4]: "
read CHOICE

case "$CHOICE" in
  1) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/IMMORTALWRT-24.10.1-FREE.bin" ;;
  2) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/NEVERMORESSH.bin" ;;
  3) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/QWRT-V1.bin" ;;
  4) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/QWRT-V2.bin" ;;
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
    sysupgrade /tmp/fwfile
    ;;
  *)
    echo "FLASH CANCELLED."
    exit 0
    ;;
esac
