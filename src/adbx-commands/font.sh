cmd_font() {
  local scale
  case "$1" in
    small)   scale=0.85 ;;
    default) scale=1    ;;
    large)   scale=1.15 ;;
    largest) scale=1.3  ;;
    *)
      echo "Usage: adbx font small|default|large|largest"
      exit 1
      ;;
  esac
  adb shell settings put system font_scale "$scale"
  echo "Font scale set to ${scale} (${1})."
}
