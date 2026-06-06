{ lib, pkgs, config, ... }:
{
  services.hyprpaper = {
    settings = {
      wallpaper = {
        monitor = "";
        path = "${../../dotfiles/wallpaper.jpg}";
        fit_mode = "cover";
      };
    };
  };
}
