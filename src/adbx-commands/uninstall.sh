cmd_uninstall() {
  local package="$1"
  if [[ -z "$package" ]]; then
    echo "Usage: adbx uninstall <package>"
    exit 1
  fi
  adb uninstall "$package"
}
