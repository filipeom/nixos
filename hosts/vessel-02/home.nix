{ lib, pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      tmux
      git
      btop
      direnv
      docker-compose
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "25.11";
  };

  imports = [
    ../../modules/programs/git.nix
    ../../modules/programs/zsh.nix
    ../../modules/programs/neovim.nix
    ../../modules/programs/wakeonlan.nix
    ../../modules/programs/tmux-sessionizer.nix
    ../../modules/home/xdg.nix
  ];

  # XDG
  xdg.enable = true;

  # programs
  programs.git.enable = true;

  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"
      '';
  };

  programs.neovim.enable = true;
  programs.wakeonlan.enable = true;

  programs.tmux-sessionizer = {
    enable = true;
    searchDirs = [ "~/projects" "~/notes" ];
  };

  # serices
  services.ssh-agent.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
