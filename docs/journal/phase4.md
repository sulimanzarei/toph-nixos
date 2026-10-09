# 2026-10-09: Phase 4, Secure Boot

**Goal:** Keep Secure Boot enabled permanently, for both NixOS and Windows.

**Result:** Secure Boot on, with my own keys. NixOS boots through Lanzaboote with every generation signed, and Windows boots with Secure Boot and TPM working. Tag `v0.5-secure-boot`.

## What I did

### How it works
The firmware only runs boot files signed by a key it trusts. Trust lives in four lists: **PK** (the platform owner), **KEK** (who may update the other lists), **db** (allowed signers) and **dbx** (revoked signatures). NixOS creates new boot files on every rebuild, so instead of a Microsoft-signed loader I became the platform owner: my own PK, KEK and db keys, with Microsoft's certificates kept so Windows and my GPU's firmware are still trusted.

### NixOS side (Secure Boot still off)
- Added `sbctl` and created my keys with `sbctl create-keys`. They're stored in `/var/lib/sbctl`, readable only by root, and never in Git.
- Added **Lanzaboote** (v1.1.0, following my nixpkgs) to the flake. It replaces the systemd-boot module (`boot.loader.systemd-boot.enable = lib.mkForce false`) and signs every generation on each rebuild.
- Applied it with `nixos-rebuild boot`. `sbctl verify` showed generations 1–9 and the boot loader all signed. The `kernel-*` files are unsigned by design, because each signed entry checks its kernel's hash.

### Firmware side
1. Checked what the firmware trusted before changing anything (read-only, with `efi-readvar`).
2. Entered Setup Mode by deleting **only the PK** in the BIOS. "Clear Secure Boot keys" would also have wiped dbx.
3. Enrolled my keys plus Microsoft's: `sbctl enroll-keys --microsoft`.
4. Set **OS Type: Windows UEFI mode**, which on ASUS means "enforce Secure Boot".

| List | Before (factory) | After |
|---|---|---|
| PK | ASUS | **mine** |
| KEK | ASUS, Microsoft 2011, Canonical | **mine**, Microsoft 2011, Microsoft **2023** |
| db | ASUS (incl. a *Notebook* key), Canonical, Microsoft 2011 (×2) | **mine**, Microsoft 2011 (×2), Microsoft **2023** (×3) |
| dbx | 15,168 bytes | 15,168 bytes (intact) |

### Verification
- **NixOS:** `bootctl status` reports `Secure Boot: enabled (user)`. "User" means my keys are in charge.
- **Windows:** `msinfo32` shows Secure Boot State On, `Get-Tpm` shows the TPM ready, and `Windows UEFI CA 2023` is in db. That resolves the `2023 cert is not in db` warning `bcdboot` gave in Phase 1.
- Set Windows to keep the hardware clock in UTC (`RealTimeIsUniversal`), like Linux, so the two systems stop fighting over the time.

## What broke or surprised me

- **`enroll-keys` failed with "File is immutable"**: Linux locks EFI variables by default, because careless writes have bricked machines. `chattr -i` unlocks the specific ones until reboot.
- **The first login with Secure Boot on took over 30 seconds.** SDDM decided the session had failed (`Session started false`) and showed the login screen again while Plasma was actually still running. Logging in again started a *second* Plasma session for the same user, which froze. The journal's logind and SDDM timeline made it clear. The next boot was fine, and nothing pointed at Secure Boot itself.

## Decisions

- **Own keys plus Microsoft only (least privilege):** ASUS and Canonical certificates were dropped. Microsoft's stay for Windows, the GPU's firmware and revocation updates. "Install Default Secure Boot keys" in the BIOS restores the factory set if ever needed.
- **Lanzaboote on NixOS 26.05:** worked with `follows = "nixpkgs"`, despite the docs only showing nixos-unstable examples.
- **Skipped the BIOS update (3611 → 3636).** A later BIOS update may reset the keys, which would mean repeating the enrollment.
- **Known limitation:** Secure Boot only proves the boot files are mine. The signing keys and root partition are unencrypted on the SSD, so physical access could still defeat it. Full protection needs disk encryption, planned for the reinstall drill.

## Next

Watch whether the slow first login comes back. Then the components phase: choosing apps (terminal, browser, launcher, headset software and more).
