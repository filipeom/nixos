{ lib, pkgs, config, ... }:
{
 home = {
    packages = with pkgs; [
      home-manager
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

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
