{ lib, pkgs, config, ... }:
{
  services.hyprpaper = {
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "${../../dotfiles/wallpaper.jpg}" ];
      wallpaper = [ ",${../../dotfiles/wallpaper.jpg}" ];
    };
  };
}
