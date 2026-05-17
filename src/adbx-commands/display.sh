cmd_display() {
  _adbx_scaled_density() {
    local factor="$1"
    local physical
    physical=$(adb shell wm density | sed -n 's/Physical density: //p' | tr -d '[:space:]\r')
    printf "%.0f" "$(echo "$physical * $factor" | bc)"
  }

  case "$1" in
    info)
      adb shell wm density
      adb shell wm size
      ;;
    default)
      adb shell wm density reset
      echo "Display density reset to default."
      ;;
    small)
      local scaled; scaled=$(_adbx_scaled_density 0.85)
      adb shell wm density "$scaled"
      echo "Display density set to ${scaled} (small, ×0.85)."
      ;;
    large)
      local scaled; scaled=$(_adbx_scaled_density 1.1)
      adb shell wm density "$scaled"
      echo "Display density set to ${scaled} (large, ×1.1)."
      ;;
    larger)
      local scaled; scaled=$(_adbx_scaled_density 1.2)
      adb shell wm density "$scaled"
      echo "Display density set to ${scaled} (larger, ×1.2)."
      ;;
    largest)
      local scaled; scaled=$(_adbx_scaled_density 1.3)
      adb shell wm density "$scaled"
      echo "Display density set to ${scaled} (largest, ×1.3)."
      ;;
    *)
      echo "Usage: adbx display info|small|default|large|larger|largest"
      exit 1
      ;;
  esac
}
