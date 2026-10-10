# toph: NixOS system configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./fonts.nix
  ];

  # Boot: Lanzaboote (signed systemd-boot) on the Samsung's EFI partition; keys in /var/lib/sbctl
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
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
    sbctl
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

  # Hyprland: tiling Wayland compositor, started through UWSM so it runs as a proper systemd session.
  # Appears at the SDDM login screen as "Hyprland (uwsm-managed)"; Plasma stays as the fallback.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Browser
  programs.firefox.enable = true;

  # NVIDIA 3070: open kernel modules:
  nixpkgs.config.allowUnfree = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
  };  

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  # To remember SSH key for session
  programs.ssh.startAgent = true;

  # The release this system was FIRST installed with. Never change it.
  system.stateVersion = "26.05";

}
