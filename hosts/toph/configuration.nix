# toph: NixOS configuration, Phase 1 (minimal , text-only)
{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Boot: systemd-boot on the Samsung's EFI partition (/boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Identity, time, language
  networking.hostName = "toph";
  time.timeZone = "Asia/Riyadh";
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking (wired DHCP now; Wi-Fi/VPN later)
  networking.networkmanager.enable = true;

  # My User
  users.users.sulimanza = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Minimal tools
  environment.systemPackages = with pkgs; [
    git
    gh
    gitleaks
    curl
    wget
    pciutils
    usbutils
    fastfetch
  ];

  # Enable modern nix commands and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Compressed swap in RAM; periodic TRIM for the SSD
  zramSwap.enable = true;
  services.fstrim.enable = true;

  # Desktop baseline: KDE Plasma 6 on Wayland, SDDM login screen
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Browser
  programs.firefox.enable = true;


  # The release this system was FIRST installed with. Never change it.
  system.stateVersion = "26.05";

  # To remember SSH key for session
  programs.ssh.startAgent = true;
}
