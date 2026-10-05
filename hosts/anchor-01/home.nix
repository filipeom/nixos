{ lib, pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      btop
      direnv
      git
      tmux
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "26.05";
  };

  imports = [
    ../../modules/programs/git.nix
    ../../modules/programs/zsh.nix
    ../../modules/programs/neovim.nix
    ../../modules/programs/tmux-sessionizer.nix
    ../../modules/home/xdg.nix
  ];

  xdg.enable = true;

  programs.git.enable = true;

  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"

      tmpd() { cd $(mktemp -d) }
      '';
  };

  programs.neovim.enable = true;

  programs.tmux-sessionizer = {
    enable = true;
    searchDirs = [ "~/projects" "~/notes" ];
  };

  # services
  services.ssh-agent.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
