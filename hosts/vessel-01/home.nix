{ lib, pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      # System config pkgs
      waybar
      hypridle
      hyprlock
      hyprshot
      kitty
      wofi
      nerd-fonts.jetbrains-mono

      # Social stuff
      thunderbird
      slack
      zulip
      mattermost-desktop
      google-chrome

      # Development
      git
      direnv
      docker-compose
      basedpyright

      # Misc
      home-manager
      tmux
      btop
      keepassxc
      nextcloud-client
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "25.11";
  };

  imports = [
    ../../modules/programs/git.nix
    ../../modules/programs/zsh.nix
    ../../modules/programs/neovim.nix
    ../../modules/programs/kitty.nix
    # Services
    ../../modules/services/hyprsunset.nix
    ../../modules/services/hyprpaper.nix
    ./xdg.nix
  ];

  # XDG
  xdg.enable = true;

  # programs
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.neovim.enable = true;
  programs.kitty.enable = true;
  programs.waybar.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    settings = {
      monitor = ",preferred,auto,auto";

      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "wofi --show drun";

      exec-once = [
        "nextcloud"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;

        border_size = 2;

        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        resize_on_border = false;
        allow_tearing = false;
        layout = "master";
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;

        active_opacity = 1.0;
        inactive_opacity = 1.0;
      };

      master = {
        new_status = "master";
        new_on_top = true;
        orientation = "left";
        mfact = 0.55;
      };

      misc = {
        force_default_wallpaper = 1;
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = "pt";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        repeat_rate = 70;
        repeat_delay = 290;
      };

      bind = [
        "$mod, P, exec, $menu"
        "$mod SHIFT, RETURN, exec, $terminal"
        "$mod SHIFT, C, killactive,"
        "$mod SHIFT, Q, exit,"
        "$mod, RETURN, layoutmsg, swapwithmaster"
        "$mod, E, exec, $fileManager"
        "$mod, F, togglefloating,"
        "$mod SHIFT, F, fullscreen,"
        "$mod, X, exec, hyprlock"

        # Move focus with mainMod + arrow keys
        "$mod, h, resizeactive, -50 0"
        "$mod, l, resizeactive, 50 0"
        "$mod, j, cyclenext, prev"
        "$mod, k, cyclenext,"

        "$mode, comma, focusmonitor, +1"
        "$mode, period, focusmonitor, -1"

        # Switch workspaces with mainMod + [0-9]
        "$mod, 1, focusworkspaceoncurrentmonitor, 1"
        "$mod, 2, focusworkspaceoncurrentmonitor, 2"
        "$mod, 3, focusworkspaceoncurrentmonitor, 3"
        "$mod, 4, focusworkspaceoncurrentmonitor, 4"
        "$mod, 5, focusworkspaceoncurrentmonitor, 5"
        "$mod, 6, focusworkspaceoncurrentmonitor, 6"
        "$mod, 7, focusworkspaceoncurrentmonitor, 7"
        "$mod, 8, focusworkspaceoncurrentmonitor, 8"
        "$mod, 9, focusworkspaceoncurrentmonitor, 9"
        "$mod, 0, focusworkspaceoncurrentmonitor, 10"

         # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Example special workspace (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with mainMod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Screenshots
        ", PRINT, exec, hyprshot -m output"
        "$mod, PRINT, exec, hyprshot -m region"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # serices
  services.ssh-agent = {
    enable = true;
    defaultMaximumIdentityLifetime = 1800;
  };

  systemd.user = {
    services = {
      waybar = import ../../modules/services/waybar.nix { inherit config pkgs lib; };
    };
  };

  services.hypridle.enable = true;
  services.hyprsunset.enable = true;
  services.hyprpaper.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
