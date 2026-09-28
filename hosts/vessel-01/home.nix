{ lib, pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      # System config pkgs
      kitty
      nerd-fonts.jetbrains-mono

      # Social stuff
      thunderbird
      slack
      zulip
      google-chrome
      deltachat-desktop
      (prismlauncher.override {
        jdks = [
          pkgs.temurin-bin-21
          pkgs.temurin-bin-17
        ];
      })

      # Development
      git
      direnv
      docker-compose
      opam
      clang
      jq
      gh

      # Misc
      home-manager
      tmux
      btop
      htop
      keepassxc
      nextcloud-client

      # Office stuff
      libreoffice-fresh
      hunspell
      hunspellDicts.en_US
      hunspellDicts.pt_PT
      texliveFull
      zathura
      zotero
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
    ../../modules/programs/tmux-sessionizer.nix
    # Services
    ../../modules/services/hyprland.nix
    ./xdg.nix
    ./gtk.nix
  ];

  # XDG
  xdg.enable = true;

  # programs
  programs.git.enable = true;

  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"

      eval $(opam env)

      tmpd() { cd $(mktemp -d) }
      '';
  };

  programs.neovim.enable = true;
  programs.kitty.enable = true;

  programs.tmux-sessionizer = {
    enable = true;
    searchDirs = [
      "~/projects"
      "~/documents/resources/notes"
    ];
  };

  programs.opencode = {
    enable = true;
    package = pkgs.writeShellScriptBin "opencode" ''
      exec ${pkgs.nodejs_26}/bin/npx -y opencode-ai@latest "$@"
    '';
    settings = {
      autoupdate = false;
      permission = "allow";
    };
  };

  programs.waybar.enable = true;

  # Hyprland environment
  my.hyprland.enable = true;

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

  # services
  services.ssh-agent.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
