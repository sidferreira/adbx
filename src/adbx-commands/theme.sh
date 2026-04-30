cmd_theme() {
  local value=""
  case "$1" in
    dark)  value="yes" ;;
    light) value="no"  ;;
    auto)  value="auto" ;;
    *)
      echo "Usage: adbx theme light|dark|auto"
      exit 1
      ;;
  esac
  adb shell "cmd uimode night $value"
}
