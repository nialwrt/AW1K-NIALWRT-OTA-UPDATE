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

echo "DOWNLOADING FIRMWARE OR SCRIPT ..."
wget -q -O /tmp/fwfile "$URL" || { echo "DOWNLOAD FAILED"; exit 1; }

printf "READY TO FLASH OR RUN. CONTINUE? (Y/N): "
read CONFIRM
case "$CONFIRM" in
  y|Y)
    if echo "$URL" | grep -q '\.sh$'; then
      echo "RUNNING INSTALLER SCRIPT ..."
      chmod +x /tmp/fwfile
      /tmp/fwfile
    else
      echo "FLASHING FIRMWARE IMAGE WITH SYSUPGRADE ..."
      sysupgrade /tmp/fwfile
    fi
    ;;
  *)
    echo "CANCELLED."
    exit 0
    ;;
esac
