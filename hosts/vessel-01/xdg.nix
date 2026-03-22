{ lib, pkgs, config, ... }:
{
  enable = true;
  configHome = "${config.home.homeDirectory}/.config";
  cacheHome = "${config.home.homeDirectory}/.cache";
  dataHome = "${config.home.homeDirectory}/.local/share";
  stateHome = "${config.home.homeDirectory}/.local/state";

  userDirs = {
    enable = true;

    desktop = "${config.home.homeDirectory}/desktop";
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";

    # PARA mapping
    music = "${config.xdg.userDirs.documents}/areas/music";
    pictures = "${config.xdg.userDirs.documents}/resources/photos";
    templates = "${config.xdg.userDirs.documents}/resources/templates";

    publicShare = "${config.home.homeDirectory}/public";
    videos = "${config.home.homeDirectory}/videos";
  };

  configFile = {
    "tmux/tmux.conf".source = ../../dotfiles/tmux/tmux.conf;
    "waybar".source = ../../dotfiles/waybar;
  };

  # Enable screensharing
  portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
}
