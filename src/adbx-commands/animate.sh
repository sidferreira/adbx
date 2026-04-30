cmd_animate() {
  case "$1" in
    on)
      adb shell settings put global window_animation_scale 1
      adb shell settings put global transition_animation_scale 1
      adb shell settings put global animator_duration_scale 1
      echo "Animations enabled."
      ;;
    off)
      adb shell settings put global window_animation_scale 0
      adb shell settings put global transition_animation_scale 0
      adb shell settings put global animator_duration_scale 0
      echo "Animations disabled."
      ;;
    *)
      echo "Usage: adbx animate on|off"
      exit 1
      ;;
  esac
}
