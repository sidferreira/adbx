cmd_record() {
  local device timestamp remote_file local_file
  device=$(adb shell getprop ro.product.model | tr -d '\r')
  timestamp=$(date +"%Y-%m-%d at %H.%M.%S")
  remote_file="/sdcard/screen_recording.mp4"
  local_file="$HOME/Desktop/ADB Screen Recording - ${device} - ${timestamp}.mp4"

  echo "Recording started... Press Enter to stop."
  adb shell screenrecord "$remote_file" &
  local bg_pid=$!

  read -r

  adb shell pkill -SIGINT screenrecord
  wait "$bg_pid" 2>/dev/null
  sleep 1

  echo "Pulling to Desktop..."
  adb pull "$remote_file" "$local_file" && adb shell rm "$remote_file"
  echo "Saved: $local_file"
}
