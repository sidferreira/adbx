cmd_wifi() {
  local ssid="$1"
  local password="$2"
  if [[ -z "$ssid" || -z "$password" ]]; then
    echo "Usage: adbx wifi <ssid> <password>"
    exit 1
  fi

  local pkg="com.steinwurf.adbjoinwifi"
  local installed
  installed=$(adb shell pm list packages | grep "$pkg")
  if [[ -z "$installed" ]]; then
    echo "Helper APK not installed. Install it first:"
    echo "  adb install adb-join-wifi.apk"
    echo "(Download from https://github.com/steinwurf/adb-join-wifi/releases)"
    exit 1
  fi

  adb shell am start -n "$pkg/.MainActivity" \
    -e ssid "$ssid" \
    -e password_type WPA \
    -e password "$password"
  sleep 3
  adb shell am force-stop "$pkg"
  echo "Attempted WiFi connection to '$ssid'."
}
