# Ram Tuning

RAM Tuning is designed to improve desktop **responsiveness** by adjusting key kernel memory parameters without installing additional software. It adapts automatically based on the system's RAM size.

![Perl](https://img.shields.io/badge/language-Perl-39457e)
![Linux](https://img.shields.io/badge/platform-Linux-blue)
![Status](https://img.shields.io/badge/status-Experimental-yellow)

## Tuned Parameters

| Parameter                 | Description                                                                 | Tuned Value (by RAM)                           |
|----------------------------|-----------------------------------------------------------------------------|------------------------------------------------|
| `vm.swappiness`            | Controls how aggressively the system uses swap. Lower = less swap.         | < 4GB: 50<br>4–8GB: 20<br>≥ 8GB: 10         |
| `vm.dirty_ratio`           | Maximum % of system memory that can be "dirty" before forcing flush.       | < 4GB: 15<br>4–8GB: 8<br>≥ 8GB: 5           |
| `vm.dirty_background_ratio`| % of memory that triggers background flush.                                 | < 4GB: 5<br>4–8GB: 2<br>≥ 8GB: 1            |

## Design Philosophy

- **Desktop-first:** Optimized for interactive systems like gaming, content creation, and daily use.
- **Adaptive:** Automatically scales parameters according to the available RAM.
- **Responsiveness over absolute throughput:** Focused on minimizing lag, stutter, and I/O stalls.

### RAM Ranges and Expected Impact

| RAM Size        | Swappiness | Dirty Ratio / Background | User Profile Impact |
|-----------------|------------|-------------------------|-------------------|
| < 4 GB          | 50         | 15 / 5                  | Moderate swap usage; avoids OOM but some latency may occur with heavy apps. |
| 4–8 GB          | 20         | 8 / 2                   | Balanced: improved responsiveness for gamers and editors; safe for multitasking. |
| ≥ 8 GB          | 10         | 5 / 1                   | Minimal swap; immediate flush; maximum responsiveness for high-performance users. |
