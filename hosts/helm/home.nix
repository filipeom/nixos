{ lib, pkgs, config, ... }:
{
  imports = [
    ../../modules/home/workstation.nix
    ../../modules/programs/wakeonlan.nix
  ];

  home = {
    packages = with pkgs; [
      # Social stuff
      discord

      # Misc
      networkmanagerapplet
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "26.05";
  };

  # programs
  programs.git = {
    signing = {
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_helm.pub";
      signByDefault = true;
    };
    settings = {
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
    };
  };

  programs.wakeonlan.enable = true;

  # Hyprland monitor layout
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1,highres@highrr,0x0,1"
      # Fallback for any unexpected extra monitors
      ",highres@highrr,1920x0,auto"
    ];

    exec-once = [
      "nextcloud"
      "nm-applet"
    ];
  };
}
