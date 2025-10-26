{ lib, pkgs, config, ... }:
{
  Unit = {
    Description="Waybar - status bar for Wayland";
    PartOf="hyprland-session.target";
    After="hyprland-session.target";
  };
  Service = {
    ExecStart="/usr/bin/waybar";
    Restart="on-failure";
    RestartSec=2;
    StandardOutput="journal";
    StandardError="journal";
  };
  Install = {
    WantedBy=["hyprland-session.target"];
  }
}
