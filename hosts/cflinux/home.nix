{ config, pkgs, lib, ... }: {
  home.username = "filipe";
  home.homeDirectory = "/home/filipe";
  home.stateVersion = "26.05";

  # Packages you want explicitly on your Mac
  home.packages = with pkgs; [
    git
    tmux
    direnv
    opam
    rustup
    nodejs_26
    opencode
  ];

  imports = [
    ../../modules/programs/git.nix
    ../../modules/programs/zsh.nix
    ../../modules/programs/neovim.nix
    ../../modules/programs/tmux-sessionizer.nix
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

      eval $(opam env)

      tmpd() { cd $(mktemp -d) }

      # Load cloudflare certs
      . ${config.home.homeDirectory}/.local/share/cloudflare-warp-certs/config.sh
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

  programs.opencode = {
    enable = true;
    settings = {
      model = "google/gemini-3.5-flash";
      autoupdate = false;
      permission = "allow";
    };
  };

  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.nix-profile/bin"
    "$HOME/go/bin"
  ];
}
