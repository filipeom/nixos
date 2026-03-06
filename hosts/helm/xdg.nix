{ lib, pkgs, config, ... }:
{
  enable = true;
  configHome = "${config.home.homeDirectory}/.config";
  cacheHome = "${config.home.homeDirectory}/.cache";
  dataHome = "${config.home.homeDirectory}/.local/share";
  stateHome = "${config.home.homeDirectory}/.local/state";

  userDirs = {
    enable = true;
    desktop = "${config.home.homeDirectory}/resources";
    documents = "${config.home.homeDirectory}/resources";
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/areas/music";
    pictures = "${config.home.homeDirectory}/resources/photos";
    publicShare = "${config.home.homeDirectory}/";
    templates = "${config.home.homeDirectory}/resources/templates";
    videos = "${config.home.homeDirectory}/";
  };

  # Some config files we need
  configFile = {
    "tmux/tmux.conf".source = ../../dotfiles/tmux/tmux.conf;
    "kitty/kitty.conf".source = ../../dotfiles/kitty/kitty.conf;
    "kitty/dayfox.conf".source = ../../dotfiles/kitty/dayfox.conf;
    "zathura/zathurarc".source = ../../dotfiles/zathura/zathura.conf;
    "waybar".source = ../../dotfiles/waybar;
    "hypr".source = ../../dotfiles/hypr;
  };

  mimeApps.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };
}
