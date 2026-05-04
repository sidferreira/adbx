cmd_animate() {
  _adbx_set_animation_scale() {
    adb shell settings put global window_animation_scale "$1"
    adb shell settings put global transition_animation_scale "$1"
    adb shell settings put global animator_duration_scale "$1"
  }

  case "$1" in
    on)
      _adbx_set_animation_scale 1
      echo "Animations enabled (scale 1)."
      ;;
    off)
      _adbx_set_animation_scale 0
      echo "Animations disabled."
      ;;
    ''|*[!0-9]*)
      echo "Usage: adbx animate on|off|<non-negative integer>"
      exit 1
      ;;
    *)
      _adbx_set_animation_scale "$1"
      if [ "$1" = "0" ]; then
        echo "Animations disabled (scale 0)."
      elif [ "$1" = "1" ]; then
        echo "Animations enabled (scale 1)."
      else
        echo "Animations set to ${1}× scale."
      fi
      ;;
  esac
}
