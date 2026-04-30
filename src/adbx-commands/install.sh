cmd_install() {
  for arg in "$@"; do
    if [[ "$arg" == *.apk ]]; then
      adb install "$arg"
      return
    fi
  done
  echo "No .apk file provided."
  exit 1
}
