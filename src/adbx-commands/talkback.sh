cmd_talkback() {
  case "$1" in
    on)
      adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService
      adb shell settings put secure accessibility_enabled 1
      echo "TalkBack enabled."
      ;;
    off)
      adb shell am force-stop com.google.android.marvin.talkback
      adb shell settings put secure accessibility_enabled 0
      echo "TalkBack disabled."
      ;;
    *)
      echo "Usage: adbx talkback on|off"
      exit 1
      ;;
  esac
}
