# adbx

Unified ADB helper. Wraps common `adb` operations behind short, memorable subcommands with zsh tab completion.

## Install

Drop `src/adbx` and `src/_adbx` into a directory on your `PATH` and `fpath`, e.g. `~/.local/bin/`:

```sh
cp src/adbx src/_adbx ~/.local/bin/
```

In `.zshrc`, make sure `~/.local/bin` is on both:

```sh
export PATH="$HOME/.local/bin:$PATH"
fpath=(~/.local/bin $fpath)
autoload -Uz compinit && compinit
```

## Commands

| Command | Description |
|---|---|
| `adbx animate on\|off` | Enable or disable animations |
| `adbx theme light\|dark\|auto` | Set system theme |
| `adbx install <file.apk>` | Install an APK |
| `adbx record` | Record screen to `~/Desktop` (Enter to stop) |
| `adbx screenshot` | Take a screenshot to `~/Desktop` |
| `adbx talkback on\|off` | Enable or disable TalkBack |
| `adbx no-password-manager` | Disable password/credential managers (emulator only) |
| `adbx auto-reverse <subcmd>` | Manage the ADB reverse daemon |
| `adbx help` | Show help |

`auto-reverse` subcommands: `listener`, `install`, `start`, `stop`, `restart`, `status`, `uninstall`, `logs`, `test`, `help`.

`no-password-manager` refuses to run unless the connected device is an emulator — it clears GMS data and disables autofill/credential services, which is only safe on AVDs.

## Layout

Each command lives in its own file under `src/commands/<name>.sh` and is sourced by `src/adbx` at startup. Completion entries live in `src/_adbx`.
