#!/bin/sh
SERVER_URL="http://192.168.1.197"
DATA_DIR="/etc/ota-client"
TOKEN_FILE="$DATA_DIR/ota_token"
TMPFW="$DATA_DIR/fwfile.bin"
SCRIPT_URL="https://raw.githubusercontent.com/nialwrt/AW1K-NIALWRT-OTA-UPDATE/refs/heads/main/aw1k-nialwrt-ota-update.sh"
TMP_SCRIPT="/tmp/update.tmp"

auto_update_script() {
  TMP_VERSIONED_URL="${SCRIPT_URL}?v=$(date +%s)"
  curl -s -L -o "$TMP_SCRIPT" "$TMP_VERSIONED_URL"
  if [ $? -eq 0 ] && ! cmp -s "$0" "$TMP_SCRIPT"; then
    echo "UPDATING SCRIPT TO LATEST VERSION..."
    cp "$TMP_SCRIPT" "$0"
    chmod +x "$0"
    exec "$0" "$@"
    exit 0
  fi
}

get_mac_address() {
  ip link show | awk '/ether/ {print $2; exit}'
}

get_name_and_mac() {
  MAC=$(get_mac_address)

  if [ -f "$TOKEN_FILE" ]; then
    STORED_NAME=$(sed -n '1p' "$TOKEN_FILE")
    STORED_MAC=$(sed -n '2p' "$TOKEN_FILE")
    if [ "$MAC" = "$STORED_MAC" ] && [ -n "$STORED_NAME" ]; then
      NAME="$STORED_NAME"
      return 0
    fi
  fi

  echo -n "ENTER YOUR NAME TO REGISTER: "
  read -r NAME
  if [ -z "$NAME" ]; then
    echo "NAME CANNOT BE EMPTY. EXITING."
    exit 1
  fi

  echo "REGISTERING TO OTA SERVER..."
  RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"name\":\"$NAME\", \"mac\":\"$MAC\"}" \
    "$SERVER_URL/register")

  echo "SERVER RESPONSE: $RESPONSE"

  STATUS=$(echo "$RESPONSE" | grep -o '"status":"[^"]*"' | cut -d':' -f2 | tr -d '"')

  if [ "$STATUS" = "ok" ]; then
    echo "$NAME" > "$TOKEN_FILE"
    echo "$MAC" >> "$TOKEN_FILE"
    echo "REGISTERED SUCCESSFULLY."
  elif [ "$STATUS" = "pending" ]; then
    echo "REGISTRATION PENDING APPROVAL. PLEASE WAIT."
    echo "Ask the admin to approve: $NAME"
    exit 1
  else
    echo "REGISTRATION FAILED. CONTACT ADMIN."
    exit 1
  fi
}

select_firmware() {
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

  case "$CHOICE" in
    1) FWNAME="IMMORTALWRT-24.10.1-LITE.bin" ;;
    2) FWNAME="OPENWRT-24.10.1-LITE.bin" ;;
    3) FWNAME="IMMORTALWRT-24.10.1-PRO.bin" ;;
    4) FWNAME="OPENWRT-24.10.1-PRO.bin" ;;
    *) echo "INVALID OPTION"; exit 1 ;;
  esac
}

download_firmware() {
  echo "REMOVING OLD FIRMWARE FILE IF ANY..."
  rm -f "$TMPFW"

  URL="$SERVER_URL/firmware.bin?name=$NAME&mac=$MAC&file=$FWNAME"
  echo "DOWNLOADING: $FWNAME"
  curl -s -L -o "$TMPFW" "$URL"

  if [ $? -ne 0 ] || [ ! -s "$TMPFW" ]; then
    echo "ERROR: FAILED TO DOWNLOAD FIRMWARE"
    rm -f "$TMPFW"
    exit 1
  fi

  echo "FIRMWARE DOWNLOADED SUCCESSFULLY: $TMPFW"
}

flash_firmware() {
  echo -n "FLASH NOW? (Y/N): "
  read -r CONFIRM
  case "$CONFIRM" in
    [Yy]* )
      echo "FLASHING..."
      sysupgrade -n "$TMPFW"
      rm -f "$TMPFW"
      ;;
    *)
      echo "ABORTED. NO FLASH."
      rm -f "$TMPFW"
      exit 0
      ;;
  esac
}

mkdir -p "$DATA_DIR"
sed -i 's/\r$//' "$0" 2>/dev/null || true

auto_update_script "$@"

if ! command -v curl >/dev/null 2>&1; then
  echo "CURL NOT FOUND. INSTALLING..."
  opkg update && opkg install curl
  if ! command -v curl >/dev/null 2>&1; then
    echo "FAILED TO INSTALL curl. EXITING."
    exit 1
  fi
fi

get_name_and_mac
select_firmware
download_firmware
flash_firmware
