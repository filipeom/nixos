{ lib, pkgs, config, ... }:
{
  gtk = {
    enable = true;
    colorScheme = "light";
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk2";
  };
}
