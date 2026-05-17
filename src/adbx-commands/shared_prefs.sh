cmd_shared_prefs() {
  local package="$1"
  if [[ -z "$package" ]]; then
    echo "Usage: adbx shared-prefs <package> list [<filename>] | remove <filename> <key>"
    exit 1
  fi
  shift

  local prefs_dir="/data/data/$package/shared_prefs"

  case "$1" in
    list)
      if [[ -n "$2" ]]; then
        adb shell run-as "$package" cat "$prefs_dir/$2"
      else
        adb shell run-as "$package" ls -al "$prefs_dir"
      fi
      ;;
    remove)
      local filename="$2"
      local key="$3"
      if [[ -z "$filename" || -z "$key" ]]; then
        echo "Usage: adbx shared-prefs <package> remove <filename> <key>"
        exit 1
      fi
      local exists
      exists=$(adb shell "run-as $package sh -c 'if [ -e $prefs_dir/$filename ]; then echo true; else echo false; fi'" | tr -d '\r')
      if [[ "$exists" != "true" ]]; then
        echo "File not found: $filename"
        exit 1
      fi
      adb shell "run-as $package sed -i '/name=\"$key\"/d' $prefs_dir/$filename"
      echo "Removed '$key' from $filename."
      ;;
    *)
      echo "Usage: adbx shared-prefs <package> list [<filename>] | remove <filename> <key>"
      exit 1
      ;;
  esac
}
