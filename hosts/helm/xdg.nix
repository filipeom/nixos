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

  # Some config files we need
  configFile = {
    "tmux/tmux.conf".source = ../../dotfiles/tmux/tmux.conf;
    "kitty/kitty.conf".source = ../../dotfiles/kitty/kitty.conf;
    "kitty/dayfox.conf".source = ../../dotfiles/kitty/dayfox.conf;
    "zathura/zathurarc".source = ../../dotfiles/zathura/zathura.conf;
    "waybar".source = ../../dotfiles/waybar;
    "hypr/hyprland.conf".source = ../../dotfiles/hypr/hyprland.conf;
    "hypr/hypridle.conf".source = ../../dotfiles/hypr/hypridle.conf;
    "hypr/hyprlock.conf".source = ../../dotfiles/hypr/hyprlock.conf;
  };

  mimeApps.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };
}
