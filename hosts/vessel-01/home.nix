{ lib, pkgs, config, ... }:
{
  imports = [
    ../../modules/home/workstation.nix
  ];

  home = {
    packages = with pkgs; [
      (prismlauncher.override {
        jdks = [
          pkgs.temurin-bin-21
          pkgs.temurin-bin-17
        ];
      })

      # Misc
      home-manager
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "25.11";
  };

  # Hyprland environment
  wayland.windowManager.hyprland.settings = {
    monitor = [
      ",highres@highrr,0x0,auto"
    ];

    input = {
      kb_layout = "us,us";
      kb_variant = ",intl";
    };

    exec-once = [
      "nextcloud"
    ];
  };

  services.hypridle.settings = {
    general = lib.mkForce { };
    listener = lib.mkForce [
      {
        timeout = 300;
        on-timeout = "systemctl suspend-then-hibernate";
      }
    ];
  };
}
