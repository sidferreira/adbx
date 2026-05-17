cmd_demo() {
  case "$1" in
    on)
      adb shell settings put global sysui_demo_allowed 1
      adb shell am broadcast -a com.android.systemui.demo -e command enter
      adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 3 -e fully true
      adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 1400
      adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
      adb shell am broadcast -a com.android.systemui.demo -e command battery -e plugged false
      adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100
      echo "Demo mode enabled."
      ;;
    off)
      adb shell am broadcast -a com.android.systemui.demo -e command exit
      adb shell settings put global sysui_demo_allowed 0
      echo "Demo mode disabled."
      ;;
    *)
      echo "Usage: adbx demo on|off"
      exit 1
      ;;
  esac
}
