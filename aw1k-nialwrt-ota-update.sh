#!/bin/sh

rm -f /tmp/update.tmp /tmp/fwfile.bin

SCRIPT_URL="https://raw.githubusercontent.com/nialwrt/AW1K-NIALWRT-OTA-UPDATE/refs/heads/main/aw1k-nialwrt-ota-update.sh"
LOCAL_SCRIPT="/usr/bin/update"
TMP_SCRIPT="/tmp/update.tmp"

# Auto update script jika ada versi baru
wget -q -O "$TMP_SCRIPT" "$SCRIPT_URL"
if [ $? -eq 0 ] && ! cmp -s "$LOCAL_SCRIPT" "$TMP_SCRIPT"; then
  echo "UPDATING SCRIPT..."
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

get_uuid_and_token() {
  if [ -f "$TOKEN_FILE" ]; then
    UUID=$(sed -n '1p' "$TOKEN_FILE")
    TOKEN=$(sed -n '2p' "$TOKEN_FILE")
    if [ -n "$UUID" ] && [ -n "$TOKEN" ]; then
      return 0
    fi
  fi

  echo -n "ENTER YOUR DEVICE UUID TO REGISTER: "
  read -r UUID
  if [ -z "$UUID" ]; then
    echo "UUID CANNOT BE EMPTY. EXITING."
    exit 1
  fi

  echo "REGISTERING TO OTA SERVER..."
  RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"uuid\":\"$UUID\"}" "$SERVER_URL/register")

  STATUS=$(echo "$RESPONSE" | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"')

  if [ "$STATUS" = "ok" ]; then
    TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*"' | cut -d':' -f2 | tr -d '"')
    echo "$UUID" > "$TOKEN_FILE"
    echo "$TOKEN" >> "$TOKEN_FILE"
    echo "REGISTERED SUCCESSFULLY WITH TOKEN."
  elif [ "$STATUS" = "pending" ]; then
    echo "REGISTRATION PENDING APPROVAL. PLEASE WAIT."
    exit 1
  else
    echo "REGISTRATION FAILED. CONTACT ADMIN."
    exit 1
  fi
}

clear
echo "####################################"
echo "      AW1K NIALWRT OTA UPDATE       "
echo "####################################"
echo " 1) IMMORTALWRT 24.10.1 LITE"
echo " 2) OPENWRT 24.10.1 LITE"
echo " 3) IMMORTALWRT 24.10.1 PRO"
echo " 4) OPENWRT 24.10.1 PRO"
echo "####################################"
echo -n "SELECT OPTION: "
read -r CHOICE

get_uuid_and_token

case "$CHOICE" in
  1) FWNAME="IMMORTALWRT-24.10.1-LITE.bin" ;;
  2) FWNAME="OPENWRT-24.10.1-LITE.bin" ;;
  3) FWNAME="IMMORTALWRT-24.10.1-PRO.bin" ;;
  4) FWNAME="OPENWRT-24.10.1-PRO.bin" ;;
  *) echo "INVALID OPTION"; exit 1 ;;
esac

URL="$SERVER_URL/firmware.bin?uuid=$UUID&token=$TOKEN&file=$FWNAME"

echo -n "DOWNLOAD & FLASH NOW? (Y/N): "
read -r CONFIRM
case "$CONFIRM" in
  [Yy]* )
    echo "DOWNLOADING: $FWNAME"
    curl -s -L -o "$TMPFW" "$URL"
    if [ $? -ne 0 ] || [ ! -s "$TMPFW" ]; then
      echo "ERROR: FAILED TO DOWNLOAD FIRMWARE"
      rm -f "$TMPFW"
      exit 1
    fi
    echo "FLASHING..."
    sysupgrade -F -n "$TMPFW"
    ;;
  *)
    echo "ABORTED. NO FIRMWARE DOWNLOAD."
    rm -f "$TMPFW"
    exit 0
    ;;
esac
