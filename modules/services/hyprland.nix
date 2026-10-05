{ lib, pkgs, config, ... }:
{
  options.my.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop environment and associated services";
  };

  imports = [
    ./hyprsunset.nix
    ./hyprpaper.nix
  ];

  config = lib.mkIf config.my.hyprland.enable {
    home.packages = with pkgs; [
      waybar
      brightnessctl
      hypridle
      hyprlock
      hyprshot
      wofi
      swaynotificationcenter
      swayosd
      inter
      gnome-backgrounds
      gsimplecal
      thunar
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      package = lib.mkDefault pkgs.hyprland;
      settings = {
        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "thunar";
        "$menu" = "wofi --show drun";

        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
        ];

        exec-once = [
          "systemctl --user start hypridle hyprsunset hyprpaper swaync swayosd"
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

          "blur:enabled" = true;
          "blur:size" = 5;
          "blur:passes" = 2;
          "blur:new_optimizations" = true;
        };

        master = {
          new_status = "inherit";
          new_on_top = true;
          orientation = "left";
          mfact = 0.55;
        };

        misc = {
          force_default_wallpaper = 1;
          disable_hyprland_logo = true;
          allow_session_lock_restore = true;
        };

        input = {
          kb_layout = lib.mkDefault "us,pt";
          kb_variant = lib.mkDefault ",";
          kb_model = "";
          kb_options = "grp:alt_shift_toggle,ctrl:nocaps";
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

          # Move focus with mainMod + hjkl
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, j, movefocus, d"
          "$mod, k, movefocus, u"

          # Move window with mainMod + SHIFT + hjkl
          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, l, movewindow, r"
          "$mod SHIFT, j, movewindow, d"
          "$mod SHIFT, k, movewindow, u"

          # Resize with mainMod + ALT + hjkl
          "ALT $mod, h, resizeactive, -40 0"
          "ALT $mod, l, resizeactive, 40 0"
          "ALT $mod, j, resizeactive, 0 40"
          "ALT $mod, k, resizeactive, 0 -40"

          "$mod, comma, focusmonitor, +1"
          "$mod, period, focusmonitor, -1"

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

        bindel = [
          ",XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
          ",XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
          ",XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
          ",XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
          ",XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
          ",XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        windowrule = [
          "match:class .*, suppress_event maximize"
          "match:class ^(pavucontrol)$, float on"
          "match:class ^(blueman-manager)$, float on"
          "match:class ^(xdg-desktop-portal-gtk)$, float on"
          "match:class ^(polkit-kde-authentication-agent-1)$, float on"
          "match:class ^(pavucontrol)$, size 50% 60%"
          "match:class ^(blueman-manager)$, size 50% 60%"
          "match:class ^(pavucontrol)$, center on"
          "match:class ^(blueman-manager)$, center on"
        ];
      };
    };

    systemd.user.services.waybar = import ./waybar.nix { inherit config pkgs lib; };

    # lidctl (clamshell/lid handling) ships its own home-manager module; it is
    # imported from the lidctl flake input in flake.nix.

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "hyprlock";
          before_sleep_cmd = "loginctl lock-session";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 900;
            on-timeout = "systemctl suspend-then-hibernate";
          }
        ];
      };
    };

    services.hyprpaper.enable = true;
    services.hyprsunset.enable = true;

    services.swaync = {
      enable = true;
      style = ../../dotfiles/swaync/style.css;
      settings = {
        positionX = "right";
        positionY = "top";
        layer = "overlay";
        control-center-layer = "top";
        layer-shell = true;
        cssPriority = "application";
        control-center-margin-top = 8;
        control-center-margin-bottom = 8;
        control-center-margin-right = 8;
        control-center-margin-left = 0;
        notification-window-width = 400;
        notification-icon-size = 48;
        notification-body-image-height = 100;
        notification-body-image-width = 200;
        timeout = 5;
        timeout-low = 3;
        timeout-critical = 0;
        fit-to-screen = true;
        relative-timestamps = true;
        image-visibility = "when-available";
        transition-time = 200;
        hide-on-clear = false;
        hide-on-action = true;
        script-fail-notify = true;
        widgets = [
          "title"
          "dnd"
          "notifications"
          "buttons-grid"
        ];
        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear All";
          };
          dnd = {
            text = "Do Not Disturb";
          };
          "buttons-grid" = {
            actions = [
              {
                label = "Calendar";
                command = "gsimplecal";
              }
            ];
          };
        };
      };
    };

    services.swayosd = {
      enable = true;
      topMargin = 0.92;
    };

    programs.wofi = {
      enable = true;
      style = ../../dotfiles/wofi/style.css;
      settings = {
        show = "drun";
        width = 600;
        height = 400;
        location = "center";
        allow_images = true;
        allow_markup = true;
        prompt = "Search...";
        insensitive = true;
        sort_order = "default";
        no_actions = true;
      };
    };
  };
}
