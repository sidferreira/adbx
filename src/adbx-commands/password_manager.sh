cmd_password_manager() {
  local kind qemu
  kind=$(adb shell getprop ro.kind 2>/dev/null | tr -d '\r')
  qemu=$(adb shell getprop ro.boot.qemu 2>/dev/null | tr -d '\r')

  if [[ "$kind" != "emulator" && "$qemu" != "1" ]]; then
    echo "Refusing to run: connected device is not an emulator."
    echo "These commands clear GMS data and toggle credential services — only safe on AVDs."
    return 1
  fi

  case "$1" in
    off)
      adb shell pm clear com.google.android.gms
      adb shell settings put secure autofill_service null
      adb shell settings put secure autofill_field_classification 0
      adb shell settings put secure autofill_feature_field_classification 0
      adb shell settings put secure credential_manager_enabled 0
      adb shell settings put secure credential_service null
      adb shell settings put secure credential_service_primary null
      echo "Password/credential managers disabled on emulator."
      ;;
    on)
      adb shell settings delete secure autofill_service
      adb shell settings delete secure credential_service
      adb shell settings delete secure credential_service_primary
      adb shell settings put secure autofill_field_classification 1
      adb shell settings put secure autofill_feature_field_classification 1
      adb shell settings put secure credential_manager_enabled 1
      echo "Password/credential managers re-enabled (system defaults restored)."
      ;;
    *)
      echo "Usage: adbx password-manager on|off"
      exit 1
      ;;
  esac
}
