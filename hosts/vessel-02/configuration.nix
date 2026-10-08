# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
      ../../modules/services/minecraft-atm10.nix
      ../../modules/services/minecraft-bmc4.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Use latest Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.page-cluster" = 0;
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.enp1s0.accept_ra" = 2;
  };

  networking.hostName = "vessel-02"; # Define your hostname.
  networking.useDHCP = false;
  networking.interfaces.enp1s0 = {
    wakeOnLan.enable = true;
    ipv4.addresses = [{
      address = "192.168.1.111";
      prefixLength = 24;
    }];
    ipv6.addresses = [{
      address = "fd00::111";
      prefixLength = 64;
    }];
  };
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "127.0.0.1" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable NetworkManager
  networking.networkmanager.enable = false;

  # WireGuard VPN server configuration
  networking.firewall.allowedUDPPorts = [ 53 443 51820 ];
  networking.firewall.allowedTCPPorts = [ 53 80 443 32400 9191 ];

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enp1s0";
    internalInterfaces = [ "wg0" ];
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" "fd00:100::1/64" ];
    listenPort = 51820;
    privateKeyFile = "/var/lib/wireguard/private.key";
    peers = [
      {
        # Windows Client
        publicKey = "l6Oc7idr8xYutd5q8uCMgqFFqjS21vq2NctNDy3vMCE=";
        allowedIPs = [ "10.100.0.2/32" "fd00:100::2/128" ];
      }
      {
        # helm
        publicKey = "tcywDJh5ZzpsEq4tdfA7D3B+bEEfmHZ6NORf7Gf7eyA=";
        allowedIPs = [ "10.100.0.10/32" "fd00:100::10/128" ];
      }
    ];
  };

  virtualisation.docker.enable = false;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  # Restrict the parent slice where systemd places all rootful containers
  systemd.slices."machine".sliceConfig = {
    AllowedCPUs = "0-3";
    MemoryMax = "16G";
  };

  virtualisation.containers.containersConf.settings = {
    containers = {
      # Mount the /nix store as read-only natively via the container engine
      volumes = [ "/nix:/nix:ro" ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pt";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.filipe = {
    isNormalUser = true;
    description = "filipe";
    extraGroups = [ "networkmanager" "wheel" "podman" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcWHhvPTxv1epTRNYeoU0XMHPDNmDbn1Vuv2JTUdncZ filipe@helm"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmNEdGpK3b2I5mzZjXbcyR1KiGpbJ4v4vt+JY7NguiC filipe@vessel-01"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSh4Y+b/P9UigBKTeGYebzpFx86iFTzVx5Jb1oVNR2r filipe@anchor-01"
    ];
  };

  programs.zsh.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    glib
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    neovim
    git
    gnutar
    gzip
    unzip
    gcc
    gnumake
    gawk
    bzip2
    btop
    nodejs_24
    python314
    rustup
    ripgrep
    tree-sitter
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Enable mDNS/Avahi for .local resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Allows the system to resolve other .local addresses
    openFirewall = true; # Automatically opens the necessary UDP port (5353)
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };

  services.github-runners.vessel-runner = {
    enable = true;
    url = "https://github.com/formalsec"; # or your org
    tokenFile = "/var/lib/github-runner/token";    # Create this file manually once
    user = "filipe";
    group = "users";
    # Uncomment the following lines if we need more disk space for the runners
    # serviceOverrides.StateDirectory = [
    #   "github-runner/vessel-runner" # module default
    #   "github-runner-work/vessel-runner"
    # ];
    # workDir = "/var/lib/github-runner-work/vessel-runner";
    nodeRuntimes = [ "node24" ];
    extraLabels = [ "self-hosted-nix" ];
    extraPackages = with pkgs; [
      docker
      curl
      gnumake
      gcc
      gnumake
      gawk
      bzip2
      bubblewrap
    ];
    serviceOverrides = {
      ProtectProc = "default";
      SupplementaryGroups = [ "podman" ];
    };
  };

  # ---- Minecraft: All the Mods 10 (NeoForge 1.21.1) ----
  # Disabled for now
  services.minecraft-atm10 = {
    enable = false;
    server-port = 25565;
    openFirewall = true;
    jvmOpts = "-Xms10G -Xmx12G -XX:+UseZGC -XX:+ZGenerational -XX:+AlwaysPreTouch";
  };

  # ---- Minecraft: Better MC [FORGE] BMC4 (Forge 1.20.1) ----
  services.minecraft-bmc4.enable = true;

  services.unbound = {
    enable = true;
    settings.server = {
      interface = [ "127.0.0.1" "192.168.1.111" ];
      access-control = [ "192.168.1.0/24 allow" ];
      local-zone = [ "home.arpa. static" "filipeom.dev. transparent" ];
      local-data = [
        ''"anchor-01.home.arpa. IN A 192.168.1.124"''
        ''"vessel-01.home.arpa. IN A 192.168.1.110"''
        ''"vessel-02.home.arpa. IN A 192.168.1.111"''
        ''"cloud.filipeom.dev. IN A 192.168.1.111"''
        ''"plex.filipeom.dev. IN A 192.168.1.111"''
        ''"grafana.filipeom.dev. IN A 194.168.1.111"''
      ];
    };
    settings.forward-zone = [ { name = "."; forward-addr = [ "1.1.1.1" "1.0.0.1" ]; } ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "filipe@filipeom.dev";

    certs."cloud.filipeom.dev" = {
      dnsProvider = "ovh";
      environmentFile = "/var/lib/acme/ovh.env";
      group = "nginx";
    };

    certs."plex.filipeom.dev" = {
      dnsProvider = "ovh";
      environmentFile = "/var/lib/acme/ovh.env";
      group = "nginx";
    };

    certs."grafana.filipeom.dev" = {
      dnsProvider = "ovh";
      environmentFile = "/var/lib/acme/ovh.env";
      group = "nginx";
    };

  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."cloud.filipeom.dev" = {
      forceSSL = true;
      useACMEHost = "cloud.filipeom.dev";
      extraConfig = ''
        client_max_body_size 10G;
      '';
      locations."/" = {
        proxyPass = "http://192.168.1.124:80";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_hide_header X-Powered-By;
          proxy_hide_header Server;
        '';
      };
    };

    virtualHosts."plex.filipeom.dev" = {
      forceSSL = true;
      useACMEHost = "plex.filipeom.dev";
      locations."/" = {
        proxyPass = "http://192.168.1.124:32400";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
      locations."= /" = {
        return = "301 https://$host/web/index.html";
      };
    };

    virtualHosts."grafana.filipeom.dev" = {
      forceSSL = true;
      useACMEHost = "grafana.filipeom.dev";
      locations."/" = {
        proxyPass = "http://192.168.1.124:3000";
        proxyWebsockets =  true;
      };
    };

    streamConfig = ''
      server {
        listen 32400;
        proxy_pass 192.168.1.124:32400;
        proxy_timeout 1h;
        proxy_connect_timeout 5s;
        proxy_socket_keepalive on;
      }
    '';
  };

  services.ddclient = {
    enable = true;
    protocol = "ovh";
    server = "www.ovh.com";
    username = "filipeom.dev-vessel-02";
    passwordFile = "/var/lib/ddclient/password";
    domains = [ "vessel-02.filipeom.dev" ];
    usev4 = "cmdv4,cmdv4=${pkgs.writeShellScript "external-ipv4" ''
      exec ${pkgs.curl}/bin/curl -4 -fsS https://ifconfig.me/ip
    ''}";
    usev6 = "cmdv6,cmdv6=${pkgs.writeShellScript "external-ipv6" ''
      exec ${pkgs.iproute2}/bin/ip -6 addr show dev enp1s0 scope global dynamic mngtmpaddr \
        | ${pkgs.gnugrep}/bin/grep inet6 | head -n1 \
        | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.coreutils}/bin/cut -d/ -f1
    ''}";
  };

  # ---- Edge abuse prevention ----
  services.fail2ban = {
    enable = true;
    bantime = "1h";
    maxretry = 3;
    bantime-increment = {
      enable = true;
      maxtime = "168h";
    };
    # Never ban local clients: the LAN and the WireGuard peers must always
    # keep access to the edge (avoids locking ourselves out).
    ignoreIP = [
      "192.168.1.0/24"
      "10.100.0.0/24"
      "fd00::/64"
      "fd00:100::/64"
    ];
    # The sshd jail is provided and enabled by the NixOS module.
    jails.nginx-botsearch.settings = {
      enabled = true;
      # nginx access logs are plain files, not in the journal.
      backend = "auto";
      logpath = "/var/log/nginx/access.log";
    };
  };

  systemd.services.fail2ban-exporter = {
    description = "Prometheus exporter for fail2ban";
    wantedBy = [ "multi-user.target" ];
    after = [ "fail2ban.service" ];
    requires = [ "fail2ban.service" ];
    serviceConfig = {
      # The fail2ban socket is root-only, so the exporter must run as root.
      ExecStart = "${pkgs.prometheus-fail2ban-exporter}/bin/fail2ban-prometheus-exporter --collector.f2b.socket=/run/fail2ban/fail2ban.sock --web.listen-address=192.168.1.111:9191";
      User = "root";
      Restart = "always";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  # ---- Observability: ship edge logs to Loki on anchor-01 ----
  services.alloy = {
    enable = true;
    extraFlags = [ "--disable-reporting" ];
  };

  # nginx writes its access log as nginx:nginx (0640).
  systemd.services.alloy.serviceConfig.SupplementaryGroups = [ "nginx" ];

  environment.etc."alloy/config.alloy".text = ''
    logging {
      level  = "warn"
      format = "logfmt"
    }

    // ---- nginx access log ----
    local.file_match "nginx" {
      path_targets = [{
        __path__ = "/var/log/nginx/access.log",
        job      = "nginx",
        host     = "vessel-02",
      }]
    }

    loki.source.file "nginx" {
      targets    = local.file_match.nginx.targets
      forward_to = [loki.process.nginx.receiver]
    }

    loki.process "nginx" {
      stage.regex {
        expression = "^(?P<remote_addr>[0-9a-fA-F:.]+) - (?P<remote_user>\\S+) \\[(?P<ts>[^\\]]+)\\] \"(?P<method>\\S+) (?P<path>\\S+) [^\"]*\" (?P<status>\\d{3}) (?P<bytes>\\d+|-)(?: \"(?P<referer>[^\"]*)\" \"(?P<user_agent>[^\"]*)\")?"
      }

      stage.geoip {
        db      = "${pkgs.dbip-city-lite.mmdb}"
        source  = "remote_addr"
        db_type = "city"
      }

      stage.labels {
        values = {
          http_status  = "status",
          method       = "method",
          country      = "geoip_country_name",
          country_code = "geoip_country_code",
          latitude     = "geoip_location_latitude",
          longitude    = "geoip_location_longitude",
        }
      }

      forward_to = [loki.write.anchor.receiver]
    }

    // ---- sshd authentication failures ----
    loki.source.journal "sshd" {
      matches    = "SYSLOG_IDENTIFIER=sshd"
      labels     = { job = "sshd", host = "vessel-02" }
      forward_to = [loki.process.sshd.receiver]
    }

    loki.process "sshd" {
      stage.regex {
        expression = "(?:Failed password|Failed publickey|Invalid user|Connection closed by|Connection reset by).*?(?P<ip>(?:\\d{1,3}\\.){3}\\d{1,3}|[0-9a-fA-F]{0,4}:[0-9a-fA-F:]+)"
      }

      stage.geoip {
        db      = "${pkgs.dbip-city-lite.mmdb}"
        source  = "ip"
        db_type = "city"
      }

      stage.labels {
        values = {
          country      = "geoip_country_name",
          country_code = "geoip_country_code",
          latitude     = "geoip_location_latitude",
          longitude    = "geoip_location_longitude",
        }
      }

      forward_to = [loki.write.anchor.receiver]
    }

    // ---- fail2ban ban/unban events ----
    loki.source.journal "fail2ban" {
      matches    = "_SYSTEMD_UNIT=fail2ban.service"
      labels     = { job = "fail2ban", host = "vessel-02" }
      forward_to = [loki.process.fail2ban.receiver]
    }

    loki.process "fail2ban" {
      stage.regex {
        expression = "\\[(?P<jail>[^\\]]+)\\] (?P<action>Ban|Unban) (?P<ip>(?:\\d{1,3}\\.){3}\\d{1,3}|[0-9a-fA-F:]+)"
      }

      stage.geoip {
        db      = "${pkgs.dbip-city-lite.mmdb}"
        source  = "ip"
        db_type = "city"
      }

      stage.labels {
        values = {
          jail         = "",
          action       = "",
          country      = "geoip_country_name",
          country_code = "geoip_country_code",
          latitude     = "geoip_location_latitude",
          longitude    = "geoip_location_longitude",
        }
      }

      forward_to = [loki.write.anchor.receiver]
    }

    loki.write "anchor" {
      endpoint {
        url = "http://192.168.1.124:3100/loki/api/v1/push"
      }
    }
  '';

  # mgmt
  services.prometheus.exporters.node.enable = true;
  services.prometheus.exporters.node.openFirewall = true;

  power.ups = {
    enable = true;
    mode = "netclient";
    upsmon.monitor.salicru = {
      system = "salicru@192.168.1.124";
      user = "upsmon";
      type = "secondary";
      passwordFile = "var/lib/nut/upsmon.password";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
