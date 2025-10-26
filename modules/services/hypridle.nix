{ lib, pkgs, config, ... }:
{
  Unit = {
    Description="Hypridle - idle manager for hyprland";
    PartOf="hyprland-session.target";
    After="hyprland-session.target";
  };
  Service = {
    ExecStart="/usr/bin/hypridle";
    Restart="on-failure";
    RestartSec=2;
    StandardOutput="journal";
    StandardError="journal";
  };
  Install = {
    WantedBy=["hyprland-session.target"];
  };
}
