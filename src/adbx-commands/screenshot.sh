cmd_screenshot() {
  local device timestamp remote_file local_file
  device=$(adb shell getprop ro.product.model | tr -d '\r')
  timestamp=$(date +"%Y-%m-%d at %H.%M.%S")
  remote_file="/sdcard/screenshot.png"
  local_file="$HOME/Desktop/ADB Screenshot - ${device} - ${timestamp}.png"

  adb shell screencap "$remote_file"
  adb pull "$remote_file" "$local_file" && adb shell rm "$remote_file"
  echo "Saved: $local_file"
}
