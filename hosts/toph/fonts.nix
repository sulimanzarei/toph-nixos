# Fonts: installed for the whole system and set as fontconfig's defaults.
# Apps that ask for "sans-serif" or "monospace" (most of them, including kitty,
# fuzzel and Hyprland's own messages) get these without any per-app setting,
# so changing a name here changes it everywhere.
{ lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    (ibm-plex.override { families = [ "sans" ]; })   # IBM Plex Sans only, not the whole Plex family
    fira-code                                          # terminal font, with ligatures
    noto-fonts                                         # contains Noto Kufi Arabic; Plasma already uses it too
    noto-fonts-color-emoji
    nerd-fonts.symbols-only                            # icon glyphs used by terminal tools (kitty also has its own copy)
  ];

  # Fallback order matters: fontconfig takes each character from the first font in
  # the list that has it. IBM Plex Sans has no Arabic letters, so Arabic text falls
  # through to Noto Kufi Arabic.
  # Plasma sets these lists as well; mkForce makes mine replace them instead of
  # being merged with them in an unpredictable order.
  fonts.fontconfig.defaultFonts = {
    sansSerif = lib.mkForce [ "IBM Plex Sans" "Noto Kufi Arabic" ];
    monospace = lib.mkForce [ "Fira Code" "Noto Kufi Arabic" "Symbols Nerd Font Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
