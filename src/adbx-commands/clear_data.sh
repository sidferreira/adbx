cmd_clear_data() {
  local package="$1"
  if [[ -z "$package" ]]; then
    echo "Usage: adbx clear-data <package>"
    exit 1
  fi
  adb shell pm clear "$package"
}
