{ pkgs, lib, ... }: {
  home.username = "fmarques";
  home.homeDirectory = "/Users/fmarques";
  home.stateVersion = "26.05";

  # Packages you want explicitly on your Mac
  home.packages = with pkgs; [
    git
    # neovim
    tmux
    direnv
    opam
    rustup
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
      key = "~/.ssh/id_macos.pub";
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

      # Helper function to safely add paths only if they exist and aren't already included
      safe_append_path() {
        if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
          export PATH="$PATH:$1"
        fi
      }

      # 1. Ensure Apple Silicon Homebrew path is loaded

      safe_prepend_path() {
        if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
          export PATH="$1:$PATH"
        fi
      }

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      # 2. Safely restore standard macOS paths that Kitty might drop
      safe_append_path "/usr/local/bin"
      safe_append_path "/System/Cryptexes/App/usr/bin"
      # load cf certs
      . ${config.home.homeDirectory}/.local/share/cloudflare-warp-certs/config.sh
      '';
    shellAliases.ls = lib.mkForce "gls --color=auto --group-directories-first";
    shellAliases.oc = "clear && opencode auth login https://opencode.cloudflare.dev && opencode mcp auth cf-portal && opencode --yolo";
  };

  programs.tmux-sessionizer = {
    enable = true;
    searchDirs = [
      "~/Projects"
      "~/Documents"
    ];
  };

  programs.neovim.enable = true;


  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];
}
