# Hyprland, user side: config files, terminal, temporary launcher, screenshot tools.
# The compositor itself is installed system-wide in hosts/toph/configuration.nix.
{ config, pkgs, ... }:

let
  # Where this repo lives on disk
  repo = "${config.home.homeDirectory}/toph-nixos";
in
{
  # ~/.config/hypr becomes a live link to home/hypr in this repo instead of a read-only copy
  # in /nix/store. Saving a .lua file there takes effect at once, with no rebuild.
  # The path is a string on purpose: a Nix path (./hypr) would be copied into the store.
  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${repo}/home/hypr";

  # Terminal. Temporary look until the colour pipeline and fonts are in place.
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.85";   # see-through, so Hyprland's blur shows behind it
      window_padding_width = 12;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };

  # Temporary app launcher until my own one in Quickshell (Phase 6).
  # Apps it starts go through UWSM, like everything else launched from Hyprland.
  programs.fuzzel = {
    enable = true;
    settings.main.launch-prefix = "uwsm app --";
  };

  # Screenshots: slurp picks a region, grim captures it, wl-copy puts it on the clipboard
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
  ];
}
