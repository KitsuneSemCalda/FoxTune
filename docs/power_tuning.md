# Power Tuning - Foxtune

Manages CPU performance mode based on power source (AC/Battery).

## Functionality

- Detects AC adapter in `/sys/class/power_supply/*/online`.
- Switches CPU governor between:
  - `performance` (AC)
  - `powersave` (Battery)
- Persists changes via udev rule at `/etc/udev/rules.d/70-foxtune-power.rules`.

## Notes

- Root privileges are required to apply changes.
- Supports `--dry-run`.
- Automatically integrates with [CPU Tuning](cpu_tuning.md).
