cmd_airplane() {
  case "$1" in
    on)
      adb shell settings put global airplane_mode_on 1
      adb shell am broadcast -a android.intent.action.AIRPLANE_MODE
      echo "Airplane mode enabled."
      ;;
    off)
      adb shell settings put global airplane_mode_on 0
      adb shell am broadcast -a android.intent.action.AIRPLANE_MODE
      echo "Airplane mode disabled."
      ;;
    *)
      echo "Usage: adbx airplane on|off"
      exit 1
      ;;
  esac
}
