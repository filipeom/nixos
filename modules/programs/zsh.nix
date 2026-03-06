{ lib, pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "direnv"
      ];
      theme = "robbyrussell";
    };
    shellAliases = {
      e = "$EDITOR";
      vi = "nvim";
      vim = "nvim";
      ls = "ls --color=auto --group-directories-first";
    };
  };
}
