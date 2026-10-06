# Hardware: toph

Collected with `inxi -Fxxz` from the NixOS 26.05 live USB on 2026-10-05. Serial numbers and MAC addresses are omitted.

| Component | Details |
|---|---|
| Motherboard | ASUS ROG STRIX B550-F GAMING (WI-FI), BIOS 3611 (2024-09-29) |
| CPU | AMD Ryzen 7 3700X, 8 cores / 16 threads (Zen 2), no integrated graphics |
| RAM | 32 GiB DDR4 |
| GPU | ZOTAC NVIDIA GeForce RTX 3070 (GA104, Ampere) |
| Primary display | LG UltraGear 27" OLED, 2560×1440, 240 Hz, DisplayPort |
| Secondary display | ViewSonic XG2431 24", 1920×1080, 240 Hz, DisplayPort |
| Ethernet | Intel I225-V 2.5 GbE (`igc` driver) |
| Wi-Fi / Bluetooth | Intel AX200 (Wi-Fi unused; Bluetooth via `btusb`) |
| Onboard audio | AMD Starship/Matisse HD Audio |
| Headset | SteelSeries Arctis Nova Pro Wireless (USB) |
| Microphone | RØDE PodMic USB |
| Webcam | AnkerWork C310 webcam |
| Mouse | Razer Viper V4 Pro |
| Keyboard | Custom QK65 |

## Storage

| Disk | Role |
|---|---|
| T-FORCE TM8FP5001T, 1 TB NVMe | Windows 11, with its own 600 MiB EFI partition since 2026-10-05 |
| Samsung SSD 860 EVO, 1 TB SATA | NixOS test bed: 1 GiB EFI partition + ext4 root |
| Seagate ST3000DM007, 3 TB HDD | Personal data and backups, BitLocker; disconnected during installs |

## Notes/Things To Be Fixed

- Under the live USB's `nouveau` driver, the LG ran at 144 Hz.
- Ethernet linked at 1 Gbps, although the card supports 2.5 Gbps.
