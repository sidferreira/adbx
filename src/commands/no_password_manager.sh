cmd_no_password_manager() {
  local kind qemu
  kind=$(adb shell getprop ro.kind 2>/dev/null | tr -d '\r')
  qemu=$(adb shell getprop ro.boot.qemu 2>/dev/null | tr -d '\r')

  if [[ "$kind" != "emulator" && "$qemu" != "1" ]]; then
    echo "Refusing to run: connected device is not an emulator."
    echo "These commands clear GMS data and disable credential services — only safe on AVDs."
    return 1
  fi

  adb shell pm clear com.google.android.gms
  adb shell settings put secure autofill_service null
  adb shell settings put secure autofill_field_classification 0
  adb shell settings put secure autofill_feature_field_classification 0
  adb shell settings put secure credential_manager_enabled 0
  adb shell settings put secure credential_service null
  adb shell settings put secure credential_service_primary null

  echo "Password/credential managers disabled on emulator."
}
