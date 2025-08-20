# IO Scheduler

> [!IMPORTANT]
> Read this document is about the explain
> why i choose use **BFQ** and **MQ-Deadline**

![Perl](https://img.shields.io/badge/language-Perl-39457e)
![Linux](https://img.shields.io/badge/platform-Linux-blue)
![Status](https://img.shields.io/badge/status-Experimental-yellow)

This module (`io_scheduler`) automatically detects storage devices and applies **optimal I/O schedulers** depending on the hardware type.

---

## Storage Device Detection

FoxTune identifies two main categories of block devices:

| Device Type | Example | Detection Method |
|------------|---------|----------------|
| NVMe SSD   | `/dev/nvme0n1` | Device name starts with `nvme` |
| SATA SSD / HDD | `/dev/sda` | All non-NVMe, non-loop, non-ram, non-dm devices |

Loop devices, RAM disks, and device-mapper (`dm-*`) volumes are **ignored** to prevent misconfiguration.

---

## I/O Scheduler Selection

FoxTune chooses schedulers based on **hardware characteristics** and **desktop workload priorities**:

| Device Type | Recommended Scheduler | Reasoning |
|------------|--------------------|----------|
| NVMe SSD | `mq-deadline` | Multi-queue + time-limited scheduling → reduces latency spikes in interactive workloads. Ideal for modern SSDs. |
| SATA SSD / HDD | `bfq` | Fair queueing between processes → improves responsiveness on rotational disks and older SSDs. |

> We prioritize **responsiveness and user experience** over raw throughput, which is critical in desktop environments.

---

## Scheduler Application Logic

1. Detect block devices.  
2. Ignore devices that are loop, ram, or dm volumes.  
3. For each device:
    - Determine the type (NVMe vs. SDA/HDD).  
    - Select scheduler:
        - `mq-deadline` for NVMe.  
        - `bfq` for SDA/HDD.  
    - Apply scheduler **immediately** if running as root.  
    - Create a **persistent udev rule** for automatic application on boot.  
4. If not running as root, print a **dry-run preview** of actions.

---

## Motivation & Design Decisions

### NVMe SSDs

These devices handle high parallelism internally.

mq-deadline avoids latency spikes from multiple processes hitting the device simultaneously.

### SATA SSD / HDD

Rotational devices benefit from fair distribution of I/O to maintain interactive performance.

BFQ ensures processes do not starve while sequential operations occur.

### Desktop-first approach

Focus on perceived responsiveness, not maximum throughput.

Avoids over-tuning for server or database workloads.

#### Persistency via udev

Scheduler settings survive reboots without requiring manual configuration.

## References

[Linux I/O Schedulers Documentation](https://www.kernel.org/doc/html/latest/block/iosched-design.html)

[BFQ Scheduler](https://www.kernel.org/doc/html/latest/block/bfq-iosched.html)

[mq-deadline Scheduler](https://www.kernel.org/doc/html/latest/block/mq-deadline-iosched.html)

[NVM Express Overview](https://en.wikipedia.org/wiki/NVM_Express)
