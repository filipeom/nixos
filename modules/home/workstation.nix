{ lib, pkgs, config, ... }:
{
  imports = [
    ./xdg.nix
    ../programs/git.nix
    ../programs/zsh.nix
    ../programs/neovim.nix
    ../programs/kitty.nix
    ../programs/ncspot.nix
    ../programs/tmux-sessionizer.nix
    # Services
    ../services/hyprland.nix
  ];

  home.packages = with pkgs; [
    # Social stuff
    thunderbird
    slack
    zulip
    google-chrome
    deltachat-desktop

    # Development
    git
    direnv
    docker-compose
    opam
    clang
    jq
    gh

    # Misc
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

  # Standard desktop user directories, mapped onto the flat home layout.
  xdg.userDirs = {
    enable = true;
    setSessionVariables = true;

    desktop = "${config.home.homeDirectory}/desktop";
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";

    music = "${config.home.homeDirectory}/media/music";
    pictures = "${config.home.homeDirectory}/media/photos";
    projects = "${config.home.homeDirectory}/projects";
    templates = "${config.home.homeDirectory}/documents/templates";
    videos = "${config.home.homeDirectory}/media/videos";
    publicShare = "${config.home.homeDirectory}/public";
  };

  xdg.configFile = {
    "waybar".source = ../../dotfiles/waybar;
    "hypr/hyprlock.conf".source = ../../dotfiles/hypr/hyprlock.conf;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

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
  programs.ncspot.enable = true;
  programs.waybar.enable = true;

  programs.tmux-sessionizer = {
    enable = true;
    searchDirs = [
      "~/projects"
      "~/notes"
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

  # Hyprland environment
  my.hyprland.enable = true;

  # services
  services.ssh-agent.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
