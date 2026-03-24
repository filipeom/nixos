{ pkgs, ... }:

let
  ecmasl-vim = pkgs.vimUtils.buildVimPlugin {
    name = "ecmasl-vim";
    src = pkgs.fetchFromGitHub {
      owner = "formalsec";
      repo = "ecmasl-vim";
      rev = "master";
      sha256 = "sha256-MEn9Zdvesa/rK7EJg4DnaZK3uCvgEuQVWK0HQjaqiiA=";
    };
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # UI
      nightfox-nvim
      barbar-nvim
      nvim-web-devicons

      # Navigation & Editing
      telescope-nvim
      plenary-nvim
      vim-fugitive
      vim-commentary

      # LSP & Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-vsnip
      vim-vsnip

      # Treesitter
      nvim-treesitter.withAllGrammars
      playground

      # Custom
      ecmasl-vim
    ];

    extraLuaConfig = ''
      require('filipeom')
    '';
  };

  # Symlink the lua configuration
  xdg.configFile."nvim/lua".source = ../../dotfiles/nvim/lua;
  xdg.configFile."nvim/after".source = ../../dotfiles/nvim/after;
  xdg.configFile."nvim/lsp".source = ../../dotfiles/nvim/lsp;
}
