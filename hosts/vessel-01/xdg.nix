{ lib, pkgs, config, ... }:
{
  enable = true;
  configHome = "${config.home.homeDirectory}/.config";
  cacheHome = "${config.home.homeDirectory}/.cache";
  dataHome = "${config.home.homeDirectory}/.local/share";
  stateHome = "${config.home.homeDirectory}/.local/state";

  configFile = {
    "tmux/tmux.conf".source = ../../dotfiles/tmux/tmux.conf;
    "nvim".source = ../../dotfiles/nvim;
  };
}
