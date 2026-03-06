{ lib, pkgs, config, ... }:
{
 home = {
    packages = with pkgs; [
      home-manager
      tmux
      neovim
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
  ];

  # XDG
  xdg = import ./xdg.nix { inherit config pkgs lib; };

  # programs

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
