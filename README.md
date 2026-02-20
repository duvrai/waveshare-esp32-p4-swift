# waveshare-esp32-p4-swift

Minimal **Embedded Swift** firmware for the [Waveshare ESP32-P4-ETH](https://www.waveshare.com/wiki/ESP32-P4-ETH) board. Uses Swift 6.3-dev with the `@c(app_main)` C interop and native `print()` over UART.

## Hardware

- **Board:** Waveshare ESP32-P4-ETH (ESP32-P4NRW32, 32 MB PSRAM, 100M Ethernet)
- **Chip:** ESP32-P4 RISC-V (rev v1.3)
- **Target:** `esp32p4` (RISC-V: `rv32imafc_zicsr_zifencei`, `ilp32f`)

## Prerequisites

- **ESP-IDF** v5.5+ (e.g. `~/esp/esp-idf`) with environment sourced (`source ~/esp/esp-idf/export.sh`)
- **Swift 6.3-dev** via [Swiftly](https://www.swift.org/install/), with `swiftc` at `~/.swiftly/bin/swiftc`
- **CMake** 3.29+

## Setup

```bash
source ~/esp/esp-idf/export.sh
export CMAKE_Swift_COMPILER="$HOME/.swiftly/bin/swiftc"
cd /path/to/waveshare-esp32-p4-swift
```

## Build

```bash
idf.py set-target esp32p4   # only needed once or after clean
idf.py build
```

App binary is ~118–122 KB. Bootloader and partition table are built for **chip revision v1.3** (see `sdkconfig.defaults`).

## Flash & monitor

```bash
idf.py -p /dev/cu.usbserial-XXXX flash
idf.py -p /dev/cu.usbserial-XXXX monitor
```

Use your board’s serial port (e.g. `cu.usbserial-*` or `usbmodem*`). Exit monitor with `Ctrl+]`.

Serial output (115200 baud): the app prints  
`Hello from Embedded Swift on Waveshare ESP32-P4-ETH!` every 2 seconds.

## Project layout

```
.
├── CMakeLists.txt          # Root; sets CMAKE_Swift_COMPILER, includes IDF
├── main/
│   ├── CMakeLists.txt      # Swift + putchar.c, Embedded Swift flags, bridging header
│   ├── BridgingHeader.h    # FreeRTOS, sdkconfig (for vTaskDelay, configTICK_RATE_HZ)
│   ├── main.swift          # @c(app_main) entry, print() loop
│   └── putchar.c           # putchar() → esp_rom_printf for native Swift print()
├── sdkconfig.defaults      # esp32p4, rev 1.x, size opts, UART0 console
├── .vscode/
│   ├── settings.json      # IDF path, Swift compiler
│   └── tasks.json         # Build, Flash & Monitor
└── .cursorrules            # Embedded Swift / toolchain conventions
```

## Configuration

- **Chip revision:** `sdkconfig.defaults` sets minimum rev for v1.3 silicon (`CONFIG_ESP32P4_REV_MIN=103` and rev &lt; 3.0 options).
- **Size:** `CONFIG_COMPILER_OPTIMIZATION_SIZE`, `-Osize`, `-enable-experimental-feature Embedded`; aim to keep app under 256 KB.
- **Serial:** UART0, 115200; `putchar.c` implements `putchar()` so Swift `print()` goes to ROM printf.

## References

- [Embedded Swift](https://www.swift.org/getting-started/embedded/)
- [Build Embedded Swift for ESP32-C6](https://developer.espressif.com/blog/build-embedded-swift-application-for-esp32c6/)
- [ESP-IDF](https://github.com/espressif/esp-idf)
- [Waveshare ESP32-P4-ETH](https://www.waveshare.com/wiki/ESP32-P4-ETH)
