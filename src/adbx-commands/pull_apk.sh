cmd_pull_apk() {
  local package="$1"
  if [[ -z "$package" ]]; then
    echo "Usage: adbx pull-apk <package>"
    exit 1
  fi
  local paths
  paths=$(adb shell pm path "$package" | sed 's/^package://' | tr -d '\r')
  if [[ -z "$paths" ]]; then
    echo "Package not found: $package"
    exit 1
  fi
  while IFS= read -r path; do
    echo "Pulling: $path"
    adb pull "$path"
  done <<< "$paths"
}
