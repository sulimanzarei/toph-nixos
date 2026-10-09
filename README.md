# toph-nixos

![NixOS 26.05](https://img.shields.io/badge/NixOS-26.05-5277C3?logo=nixos&logoColor=white)
![Flakes](https://img.shields.io/badge/Nix-flakes-7EBAE4?logo=nixos&logoColor=white)
![Secure Boot](https://img.shields.io/badge/Secure%20Boot-own%20keys-2ea44f)
![License: MIT](https://img.shields.io/badge/license-MIT-blue)

My NixOS daily-driver configuration for **toph**, my desktop PC, and the journey and documentation of building it one phase at a time.

The goal is a system that is **stable, reproducible, documented, recoverable, secure and pleasant to use**. Everything is declared in Nix and pinned, so the whole machine can be rebuilt from this repo. I'm studying cybersecurity, so security decisions and the things that broke along the way are documented as carefully as the config itself.

## Progress

| Phase | Focus | Highlights | Status | Tag |
|---|---|---|---|---|
| [0](docs/journal/phase0.md) | Preparation | Repo setup, verified install media, firmware checks | ✅ Done | |
| [1](docs/journal/phase1.md) | Installing NixOS | Found Windows silently booting from the Linux test SSD; flake + Home Manager | ✅ Done | `v0.1-minimal-install` `v0.2-flake-home-manager` |
| [2](docs/journal/phase2.md) | Desktop baseline | KDE Plasma 6 on Wayland | ✅ Done | `v0.3-plasma-baseline` |
| [3](docs/journal/phase3.md) | Drivers and hardware | NVIDIA open modules at 240 Hz, fixed corruption after suspend, traced a failed DHCP server on my home network | ✅ Done | `v0.4-hardware` |
| [4](docs/journal/phase4.md) | Secure Boot | Own Secure Boot keys with Lanzaboote; firmware trusts only my keys and Microsoft's | ✅ Done | `v0.5-secure-boot` |
| 5 | Apps and components | Terminal, shell, browser, file manager, media, communication (incl. Arabic input), headset software | ⏳ Planned | |
| 6 | Desktop comparison | Plasma vs Niri vs Hyprland as side-by-side boot entries; bar, launcher, notifications | ⏳ Planned | |
| 7 | Gaming | Steam and Proton, controllers, VRR and HDR on the OLED, per-game compatibility | ⏳ Planned | |
| 8 | Development and homelab | Dev shells, containers and VMs, SSH, Tailscale and file shares with my home server | ⏳ Planned | |
| 9 | Hardening and backups | Firewall, SSH, auditing, backups to my server, a rollback drill, the 3 TB data drive | ⏳ Planned | |
| 10 | Encrypted reinstall | Rebuild the machine from this repo onto an encrypted disk (LUKS), proving it's reproducible | ⏳ Planned | |
| 11 | Performance and polish | Benchmarks against the Phase 3 baseline, theming and fonts | ⏳ Planned | |
| 12 | Daily-driver trial | Weeks of daily use against an acceptance checklist | ⏳ Planned | |

The order of the planned phases may change as I go.

## Stack

| | |
|---|---|
| OS | NixOS 26.05, flakes, Home Manager |
| Kernel | Linux 6.18 LTS |
| Boot | Lanzaboote (signed systemd-boot), Secure Boot with my own keys |
| Desktop | KDE Plasma 6 on Wayland, SDDM |
| Graphics | NVIDIA 595 driver, open kernel modules |
| Audio | PipeWire |
| Storage | ext4 (encryption planned), zram swap, weekly TRIM |

## Hardware

| | |
|---|---|
| CPU | AMD Ryzen 7 3700X |
| GPU | NVIDIA GeForce RTX 3070 |
| RAM | 32 GB DDR4 |
| Board | ASUS ROG STRIX B550-F GAMING (WI-FI) |
| Displays | 27" 1440p 240 Hz OLED + 24" 1080p 240 Hz IPS |
| Disks | NixOS on a 1 TB SATA SSD; Windows 11 on a separate NVMe for games with kernel anti-cheat |

Full inventory: [docs/hardware.md](docs/hardware.md)

## Repository layout

```
toph-nixos/
├── flake.nix                      inputs (nixpkgs, Home Manager, Lanzaboote) and the toph system
├── flake.lock                     exact pinned versions of every input
├── hosts/toph/
│   ├── configuration.nix          system: boot, NVIDIA, desktop, audio, packages
│   └── hardware-configuration.nix generated: disks and kernel modules
├── home/sulimanza.nix             user: git with SSH commit signing, bash, rebuild aliases
└── docs/
    ├── journal/                   one entry per phase
    ├── img/                       screenshots used in the journal
    └── hardware.md                hardware inventory
```

## Principles

- **Reproducible.** Every package and setting is declared in Nix and pinned in `flake.lock`. Nothing is installed imperatively.
- **One change at a time.** Changes are tried with `nixos-rebuild test` first. Driver and boot changes use `nixos-rebuild boot`, with the previous generation as a fallback in the boot menu.
- **No secrets in Git.** A gitleaks pre-commit hook scans every commit, and every commit is SSH-signed.
- **Least privilege.** I edit the config as a normal user and only the activation step runs as root. The firmware trusts only my keys and Microsoft's, not every vendor's.
- **Document what broke.** The journal records mistakes and dead ends, not just results.

### Not in this repo, on purpose

SSH keys, Secure Boot signing keys (`/var/lib/sbctl`), passwords and access tokens. They stay on the machine. The config only describes how they're used.

## Building

This config is written for one machine. It isn't a template, but it's free to read and borrow from.

```
git clone https://github.com/sulimanzarei/toph-nixos.git ~/nixos-setup
cd ~/nixos-setup
nixos-rebuild switch --flake .#toph --sudo
```

On a fresh install, `hardware-configuration.nix` must be regenerated for the new disks, and the Secure Boot keys must be created with `sbctl create-keys` before Lanzaboote can sign anything.

## License

[MIT](LICENSE)
