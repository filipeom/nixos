{ lib, pkgs, config, ... }:
{
 home = {
    packages = with pkgs; [
      home-manager
      tmux
      git
      btop
      direnv
      docker-compose
      # lsp
      basedpyright

      kitty
      wofi
      nerd-fonts.jetbrains-mono
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "25.11";
  };

  imports = [
    ../../modules/programs/git.nix
    ../../modules/programs/zsh.nix
    ../../modules/programs/nvim.nix
  ];

  # XDG
  xdg = import ./xdg.nix { inherit config pkgs lib; };

  # programs
  programs.kitty = {
    enable = true;

    settings = {
      font_family = "JetBrainsMono Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      font_size = 14;
      force_ltr = "no";
      disable_ligatures = "never";

      box_drawing_scale = "0.001, 1, 1.5, 2";
      text_composition_strategy = "1.8 5";
      text_fg_override_threshold = 0;
    };

    extraConfig = ''
      include ${../../dotfiles/kitty/dayfox.conf}
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "wofi --show drun";
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

      ];
      monitor = ",preferred,auto,auto";
    };
  };

  # serices
  services.ssh-agent = {
    enable = true;
    defaultMaximumIdentityLifetime = 1800;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
