{ lib, pkgs, config, ... }:
{
 home = {
    packages = with pkgs; [
      home-manager
      tmux
      neovim
      git
      btop
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "25.11";
  };

  # XDG
  xdg = import ./xdg.nix { inherit config pkgs lib; };

  # programs
  programs = {
    git = import ../../modules/programs/git.nix { inherit config pkgs lib; };
    zsh = import ../../modules/programs/zsh.nix { inherit config pkgs lib; };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
