#!/bin/sh
clear
echo "###########################"
echo "AW1K NIALWRT FIRMWARE UPDATE"
echo "###########################"
echo "1) IMMORTALWRT 24.10.1 FREE"
echo "2) IMMORTALWRT 24.10.1 PRO (script)"
echo "3) NEVERMORESSH"
echo "4) QWRT V1"
echo "5) QWRT V2"
echo "###########################"
printf "ENTER YOUR CHOICE [1-5]: "
read CHOICE

case "$CHOICE" in
  1) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/IMMORTALWRT-24.10.1-FREE.bin" ;;
  2) URL="http://abidarwi.sh/nialwrt11052025.sh" ;;
  3) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/NEVERMORESSH.bin" ;;
  4) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/QWRT-V1.bin" ;;
  5) URL="https://github.com/nialwrt/AW1K-NIALWRT-FIRMWARE-UPDATE/releases/download/AW1K-FIRMWARE/QWRT-V2.bin" ;;
  *) echo "CANCELLED."; exit 0 ;;
esac

echo
echo "DOWNLOADING FROM $URL ..."
wget -q -O /tmp/firmware "$URL"
if [ $? -ne 0 ]; then
  echo "ERROR: FAILED TO DOWNLOAD FILE."
  exit 1
fi

printf "READY TO FLASH FIRMWARE. CONTINUE? (Y/N): "
read CONFIRM
case "$CONFIRM" in
  y|Y)
    if echo "$URL" | grep -qE "\.sh$"; then
      echo "RUNNING INSTALLER SCRIPT ..."
      chmod +x /tmp/firmware
      /tmp/firmware
    else
      echo "FLASHING FIRMWARE BIN ..."
      sysupgrade /tmp/firmware
    fi
    ;;
  *)
    echo "FLASH CANCELLED."
    exit 0
    ;;
esac
