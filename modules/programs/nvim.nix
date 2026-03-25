{ pkgs, ... }:

let
  ecmasl-src = pkgs.fetchFromGitHub {
    owner = "formalsec";
    repo = "ecmasl-vim";
    rev = "master";
    sha256 = "sha256-phfmBLcWSLPnuMIOWNMfzXllRjEIbzFXWbzrWCgvRFo=";
  };

  tree-sitter-ecmasl = pkgs.tree-sitter.buildGrammar {
    language = "ecmasl";
    version = "unstable";
    src = ecmasl-src;
    location = "tree-sitter-ecmasl";
  };

  ecmasl-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "ecmasl-vim";
    version = "unstable";
    src = ecmasl-src;
  };

  treesitter-with-ecmasl = pkgs.vimPlugins.nvim-treesitter.withPlugins (p:
    pkgs.vimPlugins.nvim-treesitter.allGrammars ++ [ tree-sitter-ecmasl ]
  );
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
      treesitter-with-ecmasl
      playground

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
