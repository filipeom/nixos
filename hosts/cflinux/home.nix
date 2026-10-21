{ config, pkgs, lib, ... }:
{
  home.username = "filipeom";
  home.homeDirectory = "/home/ANT.AMAZON.COM/filipeom";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    tmux
    direnv
    rustup
    nodejs_26
  ];

  imports = [
    ../../modules/programs/git.nix
    ../../modules/programs/kitty.nix
    ../../modules/programs/zsh.nix
    ../../modules/programs/neovim.nix
    ../../modules/programs/tmux-sessionizer.nix
    # Services
    ../../modules/home/xdg.nix
  ];

  xdg.enable = true;

  # programs
  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ecdsa";
      signByDefault = true;
    };
    settings = {
      user.name = lib.mkForce "Filipe Marques";
      user.email = lib.mkForce "filipeom@amazon.com";
    };
    lfs.enable = true;
    iniContent.filter.lfs = {
      clean = lib.mkForce "git-lfs clean -- %f";
      smudge = lib.mkForce "git-lfs smudge -- %f";
      process = lib.mkForce "git-lfs filter-process";
    };
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"
     '';
  };

  programs.tmux-sessionizer = {
    enable = true;
    searchDirs = [
      "~/Projects"
      "~/Notes"
    ];
  };

  programs.neovim.enable = true;

  programs.kitty = {
    enable = true;
    package = null;
  };

  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.nix-profile/bin"
    "$HOME/.toolbox/bin"
  ];
}
