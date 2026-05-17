cmd_permissions() {
  local package="$1"
  if [[ -z "$package" ]]; then
    echo "Usage: adbx permissions <package>"
    exit 1
  fi
  adb shell dumpsys package "$package" | grep -E 'granted=(true|false)'
}
