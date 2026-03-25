{ lib, pkgs, config, ... }:
{
  services.hyprpaper = {
    settings = {
      ipc = lib.mkDefault "on";
      splash = lib.mkDefault false;
      preload = lib.mkDefault [ "${../../dotfiles/wallpaper.jpg}" ];
      wallpaper = lib.mkDefault [ ",${../../dotfiles/wallpaper.jpg}" ];
    };
  };
}
