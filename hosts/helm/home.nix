{ lib, pkgs, config, ... }:
{
 home = {
    packages = with pkgs; [
      home-manager
      waybar
      hypridle
      hyprpaper
      hyprshot
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

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = ["Liberation Mono"];
    defaultFonts.sansSerif = ["Liberation Sans"];
    defaultFonts.serif = ["Liberation Serif"];
  };

   # programs
  programs.git = {
    signing = {
      format = "ssh";
      key = "~/.ssh/id_helm.pub";
      signByDefault = true;
    };
  };

  programs.zsh = {
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"

      eval $(opam env)

      tmpd() { cd $(mktemp -d) }
      '';
  };

  programs.gpg = { enable = false; };

  programs.waybar.enable = true;

  systemd.user = {
    targets = {
      hyprland-session = import ../../modules/services/hyprland.nix { inherit config pkgs lib; };
    };

    services = {
      waybar = import ../../modules/services/waybar.nix { inherit config pkgs lib; };
    };
  };

  services.gpg-agent = {
    enable = false;
    noAllowExternalCache = true;
    defaultCacheTtl = 1800;
    enableSshSupport = false;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-qt;
    pinentry.program = "pinentry-qt";
  };

  services.ssh-agent = {
    enable = true;
    defaultMaximumIdentityLifetime = 1800;
  };

  services.hypridle.enable = true;

  services.hyprsunset = {
    enable = true;
    settings = {
      max-gamma = 150;

      profile = [
        {
          time = "7:30";
          identity = true;
        }
        {
          time = "20:00";
          temperature = 4500;
          gamma = 0.8;
        }
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "${../../dotfiles/wallpaper.jpg}" ];
      wallpaper = [ ",${../../dotfiles/wallpaper.jpg}" ];
    };
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/cargo/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    NODE_REPL_HISTORY = "${config.xdg.dataHome}/node_repl_history";
    OPAMROOT = "${config.xdg.dataHome}/opam";
    XINITRC = "${config.xdg.configHome}/X11/xinitrc";
    # Rust
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME="${config.xdg.dataHome}/rustup";
  };
}
