cmd_layout() {
  case "$1" in
    show)
      adb shell setprop debug.layout true
      adb shell service call activity 1599295570
      echo "Layout bounds shown."
      ;;
    hide)
      adb shell setprop debug.layout false
      adb shell service call activity 1599295570
      echo "Layout bounds hidden."
      ;;
    *)
      echo "Usage: adbx layout show|hide"
      exit 1
      ;;
  esac
}
