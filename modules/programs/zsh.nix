{ lib, pkgs, config, ... }:
{
  programs.zsh = {
    dotDir = "${config.xdg.configHome}/zsh";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    oh-my-zsh = {
      enable = lib.mkDefault true;
      plugins = lib.mkDefault [
        "git"
        "direnv"
      ];
      theme = lib.mkDefault "robbyrussell";
    };
    shellAliases = {
      e = "$EDITOR";
      vi = "nvim";
      vim = "nvim";
      ls = "ls --color=auto --group-directories-first";
    };
  };
}
