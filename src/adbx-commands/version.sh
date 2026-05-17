cmd_version() {
  local package="$1"
  if [[ -z "$package" ]]; then
    echo "Usage: adbx version <package>"
    exit 1
  fi
  adb shell dumpsys package "$package" | grep versionName
}
