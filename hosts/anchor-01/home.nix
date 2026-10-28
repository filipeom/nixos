{ lib, pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      btop
      direnv
      git
      rtorrent
      tmux
    ];

    username = "filipe";
    homeDirectory = "/home/${config.home.username}";

    stateVersion = "26.05";

    file.".rtorrent.rc" = {
      force = true;
      text = ''
        # Instance layout
        method.insert = cfg.basedir, private|const|string, (cat,"/mnt/hdd1/rtorrent/")
        method.insert = cfg.watch,   private|const|string, (cat,(cfg.basedir),"watch/")
        method.insert = cfg.logs,    private|const|string, (cat,(cfg.basedir),"log/")
        method.insert = cfg.logfile, private|const|string, (cat,(cfg.logs),"rtorrent-",(system.time),".log")

        # Listening port (not forwarded)
        network.port_range.set = 50000-50000
        network.port_random.set = no

        # Public torrents
        dht.mode.set = auto
        protocol.pex.set = yes
        trackers.use_udp.set = yes

        # Peer/resource limits
        throttle.max_uploads.set = 100
        throttle.max_uploads.global.set = 250
        throttle.min_peers.normal.set = 20
        throttle.max_peers.normal.set = 60
        throttle.min_peers.seed.set = 30
        throttle.max_peers.seed.set = 80
        trackers.numwant.set = 80
        protocol.encryption.set = allow_incoming,try_outgoing,enable_retry

        network.http.max_open.set = 50
        network.max_open_files.set = 600
        network.max_open_sockets.set = 300
        pieces.memory.max.set = 512M
        network.xmlrpc.size_limit.set = 4M

        # Operational
        session.path.set = (cat,(cfg.basedir),"session/")
        directory.default.set = (cat,(cfg.basedir),"downloads/")
        log.execute = (cat,(cfg.logs),"execute.log")
        execute.nothrow = bash, -c, (cat,"echo >",(session.path),"rtorrent.pid"," ",(system.pid))

        encoding.add = utf8
        system.umask.set = 0027
        system.cwd.set = (directory.default)
        network.http.dns_cache_timeout.set = 25
        schedule2 = monitor_diskspace, 15, 60, ((close_low_diskspace, 10G))

        # Watch directories
        schedule2 = watch_start, 10, 10, ((load.start_verbose, (cat,(cfg.watch),"start/*.torrent")))
        schedule2 = watch_load, 11, 10, ((load.verbose, (cat,(cfg.watch),"load/*.torrent")))

        # Logging
        print = (cat, "Logging to ", (cfg.logfile))
        log.open_file = "log", (cfg.logfile)
        log.add_output = "info", "log"
      '';
    };
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
