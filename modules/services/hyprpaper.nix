{ lib, pkgs, config, ... }:
{
  Unit = {
    Description="Hyprpaper - background for hyprland";
    PartOf="hyprland-session.target";
    After="hyprland-session.target";
  };
  Service = {
    ExecStart="/usr/bin/hyprpaper";
    Restart="on-failure";
    RestartSec=2;
    StandardOutput="journal";
    StandardError="journal";
  };
  Install = {
    WantedBy=["hyprland-session.target"];
  };
}
