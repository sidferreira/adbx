cmd_launch() {
  local package="$1"
  if [[ -z "$package" ]]; then
    echo "Usage: adbx launch <package>"
    exit 1
  fi
  adb shell monkey --pct-syskeys 0 -p "$package" 1
}
