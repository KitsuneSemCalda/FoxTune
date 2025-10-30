# CPU Tuning - Foxtune

Adjusts the CPU governor and energy performance bias for each CPU.

## Functionality

- Detects if the machine is on AC power or battery.
- Possible governors:
  - `performance` when on AC.
  - `powersave` or `schedutil` when on battery.
- Adjusts `energy_perf_bias`:
  - 0 = maximum performance
  - 15 = maximum energy saving
- Persists changes via udev rule at `/etc/udev/rules.d/60-foxtune-cpu.rules`.

## Notes

- Root privileges are required to apply changes.
- Supports `--dry-run`.
- Can be integrated with [Power Tuning](power_tuning.md) for AC/battery switching.
