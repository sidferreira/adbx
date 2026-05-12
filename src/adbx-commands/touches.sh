cmd_touches() {
  case "$1" in
    on)
      adb shell settings put system show_touches 1
      adb shell settings put system pointer_location 0
      echo "Tap circles enabled."
      ;;
    verbose)
      adb shell settings put system show_touches 1
      adb shell settings put system pointer_location 1
      echo "Tap circles + pointer location overlay enabled."
      ;;
    off)
      adb shell settings put system show_touches 0
      adb shell settings put system pointer_location 0
      echo "Touch indicators disabled."
      ;;
    *)
      echo "Usage: adbx touches on|off|verbose"
      exit 1
      ;;
  esac
}
