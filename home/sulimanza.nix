{ config, pkgs, ... }:

{
  home.username = "sulimanza";
  home.homeDirectory = "/home/sulimanza";

  # Git: identity and SSH commit signing, now declared instead of `git config`
  programs.git = {
    enable = true;
    settings = {
      user.name = "sulimanza";
      user.email = "107132434+sulimanzarei@users.noreply.github.com";
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;
      init.defaultBranch = "main";
    };
  };

 
  # Bash managed by Home Manager, with shortcuts for rebuilding
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild      = "nixos-rebuild switch --flake ~/toph-nixos#toph --sudo";
      rebuild-test = "nixos-rebuild test --flake ~/toph-nixos#toph --sudo";
    };
  };

  # Same meaning as system.stateVersion: the first release used. Never change it.
  home.stateVersion = "26.05";
}
