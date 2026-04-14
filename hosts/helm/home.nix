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
    ../../modules/programs/neovim.nix
    ../../modules/programs/tmux-sessionizer.nix
    # Services
    ../../modules/services/hyprsunset.nix
    ../../modules/services/hyprpaper.nix
    ./xdg.nix
  ];


  # XDG
  xdg.enable = true;

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = ["Liberation Mono"];
    defaultFonts.sansSerif = ["Liberation Sans"];
    defaultFonts.serif = ["Liberation Serif"];
  };

   # programs
  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "~/.ssh/id_helm.pub";
      signByDefault = true;
    };
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"

      eval $(opam env)

      tmpd() { cd $(mktemp -d) }
      '';
  };

  programs.tmux-sessionizer = {
    enable = true;
    searchDirs = [
      "~/projects"
      "~/documents/resources/notes"
    ];
  };

  programs.neovim.enable = true;
  programs.gpg.enable = false;
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

  services.ssh-agent.enable = true;

  services.hypridle.enable = true;
  services.hyprsunset.enable = true;
  services.hyprpaper.enable = true;

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
