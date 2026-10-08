# 2026-10-08: Phase 3, drivers and hardware

**Goal:** Get every piece of hardware working properly on NixOS: GPU, monitors, sleep, audio, Bluetooth and webcam.

**Result:** NVIDIA's driver with both monitors at full refresh rate, working sleep, audio, Bluetooth and webcam, plus a network problem traced and fixed. Tag `v0.4-hardware`.

## What I did

### NVIDIA driver
- Switched from the open-source `nouveau` driver to NVIDIA's driver using its **open kernel modules**. Driver 595.71.05.
- The LG OLED now runs at **240 Hz** (it was stuck at 144 Hz on `nouveau`).

### Sleep
- After waking from suspend, windows left smeared trails across the screen: the GPU's memory wasn't saved during sleep.
- Fixed with `hardware.nvidia.powerManagement.enable = true`, which saves video memory to disk before sleeping and restores it on wake.

### Audio, Bluetooth, webcam
- Declared PipeWire explicitly, with PulseAudio and ALSA compatibility, so a changed default in a future release can't silently change my setup.
- Bluetooth is enabled, but the radio stays **off at boot** (`powerOnBoot = false`) since I rarely use it.
- Headset, mic and webcam all work.

### Baseline numbers

| Measurement | Value |
|---|---|
| Boot, total | 30.6 s (firmware 15.3 s, boot menu 5.5 s, kernel 1.0 s, initrd 4.5 s, userspace 4.3 s) |
| RAM in use at idle | 3.5 GiB of 31 GiB |
| GPU at idle | 23.5 W, 47 °C (two 240 Hz monitors) |

Most of the boot time is the motherboard's own startup checks and the boot menu. Linux itself takes about 10 s.

## What broke or surprised me

- **The network mystery from Phase 1** turned out to be bigger than toph:
  - `nmap --script broadcast-dhcp-discover` showed that the only DHCP server answering was my second router, a TP-Link I meant to use as an access point. It was still acting as a router and handing out `192.168.0.x` addresses.
  - After switching it to access point mode, it *still* answered, with 1-minute leases. That looked like a fallback that only kicks in when no other DHCP server responds.
  - So the real problem was that my server's DHCP (AdGuard Home) had silently stopped, most likely because the network interface name changed when I moved the server from Proxmox to CachyOS. The TP-Link had been covering for it.
- **SteelSeries' software (GG/Sonar) is Windows-only**, and only HeadsetControl is packaged for NixOS. Community replacements exist; deciding is part of the apps phase.

## Decisions

- **NVIDIA's open kernel modules**, the recommended choice for my RTX 3070.
- **DHCP stays on the server's AdGuard Home**, because my ISP router won't let me choose which DNS server it hands out, and I want ad-blocking for every device, including guests'. The trade-off is that the network depends on the server, so during the server's NixOS migration I'll temporarily switch DHCP back to the ISP router.
- **toph gets its fixed address from a DHCP reservation**, not from network settings in its NixOS config, so the config stays free of network code and every address is managed in one place.

## Next

Phase 4: Secure Boot, so it can stay enabled for both Windows and NixOS. First, check for a newer BIOS.
