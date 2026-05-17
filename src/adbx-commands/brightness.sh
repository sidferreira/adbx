cmd_brightness() {
  adb shell settings put system screen_brightness 255
  echo "Brightness set to maximum."
}
