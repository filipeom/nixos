{ lib, pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      home-manager
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "25.05";
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

  home.sessionVariables = {
    EDITOR = "nvim";
    PATH = "$HOME/.nix-profile/bin:$PATH";
  };
}
