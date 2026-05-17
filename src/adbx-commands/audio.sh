cmd_audio() {
  local stream_num
  case "$1" in
    voice-call|voice_call) stream_num=0 ;;
    system)                stream_num=1 ;;
    ring)                  stream_num=2 ;;
    music)                 stream_num=3 ;;
    alarm)                 stream_num=4 ;;
    notification)          stream_num=5 ;;
    dtmf)                  stream_num=8 ;;
    accessibility)         stream_num=10 ;;
    *)
      echo "Usage: adbx audio voice-call|system|ring|music|alarm|notification|dtmf|accessibility"
      exit 1
      ;;
  esac
  for i in {1..20}; do
    adb shell media volume --stream "$stream_num" --adj lower
  done
  echo "Audio stream '$1' muted."
}
