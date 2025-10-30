# Network Tuning - Foxtune

Optimizes TCP buffers and congestion control for better throughput and latency.

## Tuned Parameters

| Parameter                           | Value                               |
|------------------------------------|------------------------------------|
| `net.core.rmem_max`                 | 16777216                            |
| `net.core.wmem_max`                 | 16777216                            |
| `net.ipv4.tcp_rmem`                 | 4096 87380 16777216                |
| `net.ipv4.tcp_wmem`                 | 4096 65536 16777216                |
| `net.ipv4.tcp_congestion_control`   | bbr                                 |
| `net.ipv4.tcp_slow_start_after_idle` | 0                                   |

## Persistence

- Creates `/etc/sysctl.d/99-foxtune-net.conf`.
- Applies changes with `sysctl -p`.
- Supports `--dry-run`.

## Notes

- Works together with [RAM Tuning](ram_tuning.md) to avoid excessive swapping.
