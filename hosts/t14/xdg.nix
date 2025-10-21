{ lib, pkgs, config, ... }:
{
  enable = true;
  configHome = "${config.home.homeDirectory}/.config";
  cacheHome = "${config.home.homeDirectory}/.cache";
  dataHome = "${config.home.homeDirectory}/.local/share";
  stateHome = "${config.home.homeDirectory}/.local/state";

  userDirs = {
    enable = true;
    desktop = "${config.home.homeDirectory}/resources";
    documents = "${config.home.homeDirectory}/resources";
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/areas/music";
    pictures = "${config.home.homeDirectory}/resources/photos";
    publicShare = "${config.home.homeDirectory}/";
    templates = "${config.home.homeDirectory}/resources/templates";
    videos = "${config.home.homeDirectory}/";
  };

  # Some config files we need
  configFile = {
    "tmux/tmux.conf".source = ../../dotfiles/tmux/tmux.conf;
    "kitty/kitty.conf".source = ../../dotfiles/kitty/kitty.conf;
    "kitty/dayfox.conf".source = ../../dotfiles/kitty/dayfox.conf;
    "zathura/zathurarc".source = ../../dotfiles/zathura/zathura.conf;
    # TODO: Find a better way to do this
    "nvim/init.lua".source = ../../dotfiles/nvim/init.lua;
    "nvim/lua/filipeom/init.lua".source = ../../dotfiles/nvim/lua/filipeom/init.lua;
    "nvim/lua/filipeom/cmd.lua".source = ../../dotfiles/nvim/lua/filipeom/cmd.lua;
    "nvim/lua/filipeom/plugins.lua".source = ../../dotfiles/nvim/lua/filipeom/plugins.lua;
    "nvim/lua/filipeom/remap.lua".source = ../../dotfiles/nvim/lua/filipeom/remap.lua;
    "nvim/lua/filipeom/set.lua".source = ../../dotfiles/nvim/lua/filipeom/set.lua;
    "nvim/lua/filipeom/lsp.lua".source = ../../dotfiles/nvim/lua/filipeom/lsp.lua;
    "nvim/lsp".source = ../../dotfiles/nvim/lsp;
    "nvim/after/plugin/barbar.lua".source = ../../dotfiles/nvim/after/plugin/barbar.lua;
    "nvim/after/plugin/cmp.lua".source = ../../dotfiles/nvim/after/plugin/cmp.lua;
    "nvim/after/plugin/colors.lua".source = ../../dotfiles/nvim/after/plugin/colors.lua;
    "nvim/after/plugin/fugitive.lua".source = ../../dotfiles/nvim/after/plugin/fugitive.lua;
    # "nvim/after/plugin/lsp.lua".source = ../../dotfiles/nvim/after/plugin/lsp.lua;
    "nvim/after/plugin/telescope.lua".source = ../../dotfiles/nvim/after/plugin/telescope.lua;
    "nvim/after/plugin/treesitter.lua".source = ../../dotfiles/nvim/after/plugin/treesitter.lua;
    "nvim/after/plugin/mason.lua".source = ../../dotfiles/nvim/after/plugin/mason.lua;
  };

  mimeApps.defaultApplications = {
    "application/pdf" = "org.pwmt.zathura.desktop";
  };
}
