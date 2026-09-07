{ config, pkgs, lib, ... }:
{
  home.username = "filipe";
  home.homeDirectory = "/home/filipe";
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
    ./xdg.nix
  ];

  xdg.enable = true;

  # programs
  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519";
      signByDefault = true;
    };
    settings = {
      user.name = lib.mkForce "Filipe Marques";
      user.email = lib.mkForce "fmarques@cloudflare.com";
    };
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -s ^f "tmux-sessionizer\n"

      tmpd() { cd $(mktemp -d) }
     '';
    shellAliases.oc = "clear && opencode auth login https://opencode.cloudflare.dev && opencode mcp auth cf-portal && opencode";
  };

  programs.tmux-sessionizer = {
    enable = true;
    searchDirs = [
      "~/Projects"
      "~/Documents"
    ];
  };

  programs.neovim.enable = true;

  programs.kitty = {
    enable = true;
    package = null;
  };

  programs.opencode = {
    enable = true;
    package = pkgs.writeShellScriptBin "opencode" ''
      exec ${pkgs.nodejs_26}/bin/npx -y opencode-ai@latest "$@"
    '';
    settings = {
      model = "google/gemini-3.8-flash";
      autoupdate = false;
      permission = "allow";
      lsp = true;
    };
  };

  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.nix-profile/bin"
    "$HOME/go/bin"
  ];
}
