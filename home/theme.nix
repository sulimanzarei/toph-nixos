# Wallpapers and colours: awww draws the wallpaper, matugen builds the palette,
# and the toph-theme command ties them together.
{ config, pkgs, ... }:

let
  repo = "${config.home.homeDirectory}/toph-nixos";
  state = "${config.xdg.stateHome}/toph";   # ~/.local/state/toph: current wallpaper, mode and generated colours

  # home/scripts/toph-theme.sh turned into a command. writeShellApplication puts
  # the listed programs on its PATH and refuses to build if shellcheck finds a problem.
  toph-theme = pkgs.writeShellApplication {
    name = "toph-theme";
    runtimeInputs = with pkgs; [ awww matugen jq coreutils findutils ];
    text = builtins.readFile ./scripts/toph-theme.sh;
  };
in
{
  home.packages = [
    pkgs.awww      # wallpaper daemon; started by Hyprland (see home/hypr/hyprland.lua)
    pkgs.matugen
    toph-theme
  ];

  # matugen settings. Templates are read straight from the repo, so they can be
  # changed without a rebuild; the filled-in copies go to ~/.local/state/toph.
  xdg.configFile."matugen/config.toml".source = (pkgs.formats.toml { }).generate "matugen-config" {
    config.fallback_color = "#0d73cc";
    templates = {
      hyprland = {
        input_path = "${repo}/home/matugen/hyprland-colors.lua";
        output_path = "${state}/hyprland-colors.lua";
        post_hook = "hyprctl reload >/dev/null";   # look.lua reads the new colours on reload
      };
      kitty = {
        input_path = "${repo}/home/matugen/kitty-colors.conf";
        output_path = "${state}/kitty-colors.conf";
        post_hook = "pkill -USR1 kitty || true";   # SIGUSR1 makes kitty reload its config
      };
    };
  };

  # kitty picks up the generated colours. A plain include with a full path: if the
  # file doesn't exist yet, kitty only logs a line instead of showing an error window.
  # (globinclude only takes patterns relative to ~/.config/kitty.)
  programs.kitty.extraConfig = ''
    include ${state}/kitty-colors.conf
  '';
}
