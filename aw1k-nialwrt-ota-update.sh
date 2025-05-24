#!/bin/sh

rm -f /tmp/update.tmp /tmp/fwfile.bin

SCRIPT_URL_ORIGINAL="https://raw.githubusercontent.com/nialwrt/AW1K-NIALWRT-OTA-UPDATE/main/aw1k-nialwrt-ota-update.sh"
LOCAL_SCRIPT="/usr/bin/update"
TMP_SCRIPT="/tmp/update.tmp"

wget -q -O "$TMP_SCRIPT" "$SCRIPT_URL_ORIGINAL"

if [ $? -eq 0 ] && ! cmp -s "$LOCAL_SCRIPT" "$TMP_SCRIPT"; then
  echo "Updating OTA client script..."
  cp "$TMP_SCRIPT" "$LOCAL_SCRIPT"
  chmod +x "$LOCAL_SCRIPT"
  exec "$LOCAL_SCRIPT" "$@"
  exit 0
fi

SERVER_URL="http://192.168.1.197"
DATA_DIR="/etc/ota-client"
TOKEN_FILE="$DATA_DIR/ota_token"
TMPFW="$DATA_DIR/fwfile.bin"

mkdir -p "$DATA_DIR"

sed -i 's/\r$//' "$0" 2>/dev/null || true

get_token_and_name() {
  if [ -f "$TOKEN_FILE" ]; then
    NAME=$(sed -n '1p' "$TOKEN_FILE")
    TOKEN=$(sed -n '2p' "$TOKEN_FILE")
    [ -n "$NAME" ] && [ -n "$TOKEN" ] && return 0
  fi

  echo -n "ENTER YOUR NAME TO REGISTER: "
  read -r NAME
  if [ -z "$NAME" ]; then
    echo "Name required. Exiting."
    exit 1
  fi

  echo "REGISTERING TO OTA SERVER..."
  RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"name\":\"$NAME\"}" "$SERVER_URL/register")

  TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*"' | cut -d':' -f2 | tr -d '"')

  if [ -z "$TOKEN" ]; then
    echo "Failed to register. Response: $RESPONSE"
    exit 1
  fi

  echo "$NAME" > "$TOKEN_FILE"
  echo "$TOKEN" >> "$TOKEN_FILE"
  echo "REGISTERED SUCCESSFULLY AS $NAME"
}

clear
echo "####################################"
echo "          OTA CLIENT UPDATE         "
echo "####################################"
echo " 1) IMMORTALWRT 24.10.1 LITE"
echo " 2) OPENWRT 24.10.1 LITE"
echo " 3) IMMORTALWRT 24.10.1 PRO"
echo " 4) OPENWRT 24.10.1 PRO"
echo "####################################"
echo -n "SELECT OPTION: "
read -r CHOICE

get_token_and_name

case "$CHOICE" in
  1) FWNAME="IMMORTALWRT-24.10.1-LITE.bin" ;;
  2) FWNAME="OPENWRT-24.10.1-LITE.bin" ;;
  3) FWNAME="IMMORTALWRT-24.10.1-PRO.bin" ;;
  4) FWNAME="OPENWRT-24.10.1-PRO.bin" ;;
  *) echo "INVALID OPTION"; exit 1 ;;
esac

URL="$SERVER_URL/firmware.bin?name=$NAME&token=$TOKEN&file=$FWNAME"
echo "DOWNLOADING FIRMWARE...
curl -L -o "$TMPFW" "$URL"

if [ $? -ne 0 ] || [ ! -s "$TMPFW" ]; then
  echo "ERROR: FAILED TO DOWNLOAD FIRMWARE"
  exit 1
fi

echo -n "FLASH NOW? (Y/N): "
read -r CONFIRM
case "$CONFIRM" in
  [Yy]* )
    echo "FLASHING..."
    sysupgrade -n "$TMPFW"
    ;;
  *)
    echo "Aborted."
    exit 0
    ;;
esac
