AR_PLIST_NAME="com.adb-auto-reverse.daemon.plist"
AR_LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
AR_LOG_FILE="$HOME/.adb-auto-reverse.log"
AR_POLL_INTERVAL=2

_ar_print_status()  { echo -e "\033[0;32m[INFO]\033[0m $1" }
_ar_print_warning() { echo -e "\033[1;33m[WARN]\033[0m $1" }
_ar_print_error()   { echo -e "\033[0;31m[ERROR]\033[0m $1" }

_ar_log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$AR_LOG_FILE"
  /usr/bin/log default --subsystem "com.adb-auto-reverse.daemon" --category "monitoring" -- "$1"
}

_ar_notify() {
  osascript -e "display notification \"$2\" with title \"$1\""
}

_ar_check_adb() {
  if ! command -v adb &> /dev/null; then
    if [[ "$1" == "install" ]]; then
      _ar_print_error "adb command not found!"
      _ar_print_warning "Install Android SDK platform-tools: brew install android-platform-tools"
      return 1
    else
      _ar_log "ERROR: adb command not found."
      _ar_notify "ADB Error" "adb command not found. Install Android SDK platform-tools."
      exit 1
    fi
  fi
}

_ar_get_devices() {
  adb devices | grep -E "device$" | cut -f1
}

_ar_setup_reverse() {
  local device_id="$1"
  _ar_log "Setting up ADB reverse for device: $device_id"
  if adb -s "$device_id" reverse tcp:8081 tcp:8081 2>/dev/null; then
    _ar_log "SUCCESS: ADB reverse set for device $device_id"
    _ar_notify "ADB Reverse" "ADB Reverse set for device $device_id"
  else
    _ar_log "ERROR: Failed to set ADB reverse for device $device_id"
    _ar_notify "ADB Error" "Failed to set ADB reverse for device $device_id"
  fi
}

_ar_is_emulator() {
  local device_id="$1" kind qemu
  kind=$(adb -s "$device_id" shell getprop ro.kind 2>/dev/null | tr -d '\r')
  qemu=$(adb -s "$device_id" shell getprop ro.boot.qemu 2>/dev/null | tr -d '\r')
  [[ "$kind" == "emulator" || "$qemu" == "1" ]]
}

_ar_prompt_disable_pm() {
  local device_id="$1" choice
  choice=$(osascript 2>/dev/null <<EOF
tell application "System Events"
  activate
  set msg to "Emulator $device_id just connected." & return & return & "Disable password/credential managers on this emulator?"
  set d to display dialog msg buttons {"Skip", "Disable"} default button "Skip" with title "adbx auto-reverse" with icon caution giving up after 60
  return button returned of d
end tell
EOF
)
  [[ "$choice" == "Disable" ]]
}

_ar_offer_disable_pm() {
  local device_id="$1"
  if ! _ar_is_emulator "$device_id"; then
    return 0
  fi
  _ar_log "Emulator detected ($device_id); prompting to disable password manager"
  if _ar_prompt_disable_pm "$device_id"; then
    _ar_log "User opted to disable password manager on $device_id"
    ANDROID_SERIAL="$device_id" cmd_password_manager off >> "$AR_LOG_FILE" 2>&1
    _ar_notify "Password Manager" "Disabled on $device_id"
  else
    _ar_log "User skipped password manager prompt for $device_id"
  fi
}

_ar_monitor_devices() {
  local known_devices=()
  _ar_log "Starting Android device monitoring..."
  _ar_notify "Device Monitor" "Android device monitoring started"

  while true; do
    local current_devices=($(adb devices | grep -E "device$" | cut -f1))

    for device in "${current_devices[@]}"; do
      if [[ ! " ${known_devices[@]} " =~ " ${device} " ]]; then
        _ar_log "New device detected: $device"
        _ar_setup_reverse "$device"
        _ar_offer_disable_pm "$device"
        known_devices+=("$device")
      fi
    done

    local updated=()
    for known in "${known_devices[@]}"; do
      if [[ " ${current_devices[@]} " =~ " ${known} " ]]; then
        updated+=("$known")
      else
        _ar_log "Device disconnected: $known"
      fi
    done
    known_devices=("${updated[@]}")

    sleep "$AR_POLL_INTERVAL"
  done
}

_ar_create_plist() {
  local script_path="$1" adb_dir="$2"
  cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.adb-auto-reverse.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>$script_path</string>
        <string>auto-reverse</string>
        <string>listener</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Background</string>
    <key>StandardOutPath</key>
    <string>/tmp/adb-auto-reverse.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/adb-auto-reverse.err</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$adb_dir:/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
    </dict>
    <key>WorkingDirectory</key>
    <string>/tmp</string>
    <key>ThrottleInterval</key>
    <integer>10</integer>
</dict>
</plist>
EOF
}

cmd_auto_reverse() {
  local subcmd="$1"; shift

  case "$subcmd" in
    listener)
      echo "adbx auto-reverse - Starting monitoring..."
      echo "Log: $AR_LOG_FILE"
      echo "Press Ctrl+C to stop"
      trap '_ar_log "Shutting down..."; _ar_notify "Device Monitor" "Android device monitoring stopped"; exit 0' SIGTERM SIGINT
      _ar_check_adb
      _ar_monitor_devices
      ;;
    install)
      _ar_print_status "Installing auto-reverse daemon..."
      if ! _ar_check_adb "install"; then
        _ar_print_error "Installation aborted"
        return 1
      fi
      _ar_print_status "adb found at: $(which adb)"
      mkdir -p "$AR_LAUNCH_AGENTS_DIR"
      local script_path="${ADBX_SCRIPT:A}"
      local adb_dir="$(dirname "$(which adb)")"
      _ar_create_plist "$script_path" "$adb_dir" > "$AR_LAUNCH_AGENTS_DIR/$AR_PLIST_NAME"
      _ar_print_status "Launch Agent installed. Run 'adbx auto-reverse start' to begin."
      ;;
    start)
      if [[ ! -f "$AR_LAUNCH_AGENTS_DIR/$AR_PLIST_NAME" ]]; then
        _ar_print_error "Not installed. Run 'adbx auto-reverse install' first."
        return 1
      fi
      _ar_print_status "Starting auto-reverse daemon..."
      launchctl load "$AR_LAUNCH_AGENTS_DIR/$AR_PLIST_NAME" 2>/dev/null \
        && _ar_print_status "Started." \
        || _ar_print_warning "May already be running. Check with 'adbx auto-reverse status'."
      ;;
    stop)
      _ar_print_status "Stopping auto-reverse daemon..."
      launchctl unload "$AR_LAUNCH_AGENTS_DIR/$AR_PLIST_NAME" 2>/dev/null \
        && _ar_print_status "Stopped." \
        || _ar_print_warning "Service may not be running."
      ;;
    restart)
      _ar_print_status "Restarting auto-reverse daemon..."
      launchctl unload "$AR_LAUNCH_AGENTS_DIR/$AR_PLIST_NAME" 2>/dev/null
      sleep 2
      launchctl load "$AR_LAUNCH_AGENTS_DIR/$AR_PLIST_NAME" 2>/dev/null
      _ar_print_status "Restarted."
      ;;
    status)
      if launchctl list | grep -q "com.adb-auto-reverse.daemon"; then
        _ar_print_status "Service is running."
        if [[ -f "$AR_LOG_FILE" ]]; then
          echo ""
          echo "Recent log entries:"
          tail -n 5 "$AR_LOG_FILE"
        fi
      else
        _ar_print_warning "Service is not running."
      fi
      echo ""
      echo "Connected devices:"
      adb devices
      ;;
    uninstall)
      _ar_print_status "Uninstalling auto-reverse daemon..."
      launchctl unload "$AR_LAUNCH_AGENTS_DIR/$AR_PLIST_NAME" 2>/dev/null
      rm -f "$AR_LAUNCH_AGENTS_DIR/$AR_PLIST_NAME"
      _ar_print_status "Uninstalled."
      ;;
    logs)
      if [[ -f "$AR_LOG_FILE" ]]; then
        if [[ "$1" == "-f" || "$1" == "--follow" ]]; then
          tail -f "$AR_LOG_FILE"
        else
          tail -n 20 "$AR_LOG_FILE"
        fi
      else
        _ar_print_warning "Log file not found at $AR_LOG_FILE"
      fi
      ;;
    test)
      _ar_print_status "Running in foreground (Ctrl+C to stop)..."
      _ar_check_adb
      _ar_monitor_devices
      ;;
    help|--help|-h|"")
      echo "Usage: adbx auto-reverse <subcommand>"
      echo ""
      echo "Subcommands:"
      echo "  listener   Start device monitoring (used by background service)"
      echo "  install    Install the background service"
      echo "  start      Start the background service"
      echo "  stop       Stop the background service"
      echo "  restart    Restart the background service"
      echo "  status     Check if service is running"
      echo "  uninstall  Remove the service"
      echo "  logs       Show recent log entries"
      echo "  logs -f    Follow log file in real-time"
      echo "  test       Run manually in foreground"
      echo "  help       Show this help"
      ;;
    *)
      _ar_print_error "Unknown subcommand: $subcmd"
      echo ""
      cmd_auto_reverse help
      exit 1
      ;;
  esac
}
