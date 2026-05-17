cmd_reboot() {
  echo "Rebooting device..."
  adb reboot
  echo "Waiting for device..."
  adb wait-for-device
  local i=0
  while [[ $i -lt 60 ]]; do
    local booted
    booted=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    if [[ "$booted" == "1" ]]; then
      echo "Device ready."
      return 0
    fi
    sleep 1
    (( i++ ))
  done
  echo "Device did not complete boot within 60 seconds."
  exit 1
}
