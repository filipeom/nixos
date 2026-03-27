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
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "25.11";
  };

  imports = [
    ../../modules/programs/git.nix
    ../../modules/programs/zsh.nix
    ../../modules/programs/neovim.nix
    ./xdg.nix
  ];

  # XDG
  xdg.enable = true;

  # programs
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.neovim.enable = true;

  # serices
  services.ssh-agent.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
