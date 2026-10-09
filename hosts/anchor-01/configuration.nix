# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
      ../../modules/services/nut-watchdog.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep the UPS's buggy USB HID firmware from wedging under runtime PM.
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  networking.hostName = "anchor-01"; # Define your hostname.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6 = {
    ipv4.addresses = [ { address = "192.168.1.124"; prefixLength = 24; } ];
  };
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.111" "1.1.1.1" ];
  networking.search = [ "home.arpa" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = false;

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
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."filipe" = {
    isNormalUser = true;
    description = "filipe";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcWHhvPTxv1epTRNYeoU0XMHPDNmDbn1Vuv2JTUdncZ filipe@helm"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmNEdGpK3b2I5mzZjXbcyR1KiGpbJ4v4vt+JY7NguiC filipe@vessel-01"
    ];
  };

  programs.zsh.enable = true;

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
    smartmontools
    zstd
    rsync
    tmux
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  virtualisation.containers.containersConf.settings = {
    containers = {
      # Mount the /nix store as read-only natively via the container engine
      volumes = [ "/nix:/nix:ro" ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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

  # Plex Media Server
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  # Nextcloud
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud35;
    hostName = "cloud.filipeom.dev";
    datadir = "/mnt/hdd/home/nextcloud";
    https = true;
    maxUploadSize = "10G";
    database.createLocally = true;
    config = {
      dbtype = "mysql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      adminuser = null;
    };
    settings = {
      overwriteprotocol = "https";
      trusted_domains = [ "192.168.1.124" ];
      trusted_proxies = [ "192.168.1.111" ];
      default_phone_region = "PT";
    };
    secrets = {
      instanceid   = "/var/lib/nextcloud-secrets/instanceid";
      secret       = "/var/lib/nextcloud-secrets/secret";
      passwordsalt = "/var/lib/nextcloud-secrets/passwordsalt";
    };
    configureRedis = true;
    extraApps = {
      spreed   = pkgs.nextcloud35Packages.apps.spreed;
      contacts = pkgs.nextcloud35Packages.apps.contacts;
      notes    = pkgs.nextcloud35Packages.apps.notes;
      tasks    = pkgs.nextcloud35Packages.apps.tasks;
    };
  };

  # Grafana
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    stateDir = "prometheus";         # /var/lib/prometheus (NVMe)
    retentionTime = "90d";
    enableReload = true;

    rules = [
      ''
        groups:
          - name: nut
            rules:
              - alert: NUTExporterDown
                expr: up{job="nut"} == 0
                for: 2m
                labels:
                  severity: critical
                annotations:
                  summary: NUT exporter on {{ $labels.instance }} is down

              - alert: UPSDataStale
                expr: absent(network_ups_tools_ups_status)
                for: 2m
                labels:
                  severity: critical
                annotations:
                  summary: UPS metrics missing, NUT driver is likely stale

              - alert: UPSOnBattery
                expr: network_ups_tools_ups_status{flag="OB"} == 1
                for: 1m
                labels:
                  severity: warning
                annotations:
                  summary: UPS is running on battery

              - alert: UPSLowBattery
                expr: network_ups_tools_ups_status{flag="LB"} == 1
                labels:
                  severity: critical
                annotations:
                  summary: UPS battery is low
      ''
    ];

    scrapeConfigs = [
      { job_name = "prometheus"; static_configs = [{ targets = [ "127.0.0.1:9090" ]; }]; }
      { job_name = "nut";
        metrics_path = "/ups_metrics";
        static_configs = [{ targets = [ "127.0.0.1:9199" ]; }];
      }
      { job_name = "node";
        static_configs = [
          { targets = [ "127.0.0.1:9100" ];   labels.instance = "anchor-01"; }
          { targets = [ "192.168.1.110:9100" ]; labels.instance = "vessel-01"; }
          { targets = [ "192.168.1.111:9100" ]; labels.instance = "vessel-02"; }
        ];
      }
      { job_name = "fail2ban";
        static_configs = [
          { targets = [ "192.168.1.111:9191" ]; labels.instance = "vessel-02"; }
        ];
      }
    ];

    exporters = {
      node = { enable = true; listenAddress = "127.0.0.1"; };
      nut.enable = true;
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        protocol = "http";
        http_addr = "192.168.1.124";
        http_port = 3000;
        domain = "grafana.filipeom.dev";
        root_url = "https://grafana.filipeom.dev/";
        serve_from_sub_path = false;
      };
      security = {
        admin_user = "filipe";
        admin_password = "$__file{/var/lib/grafana-secrets/admin_password}";
        secret_key     = "$__file{/var/lib/grafana-secrets/secret_key}";
      };
      analytics.reporting_enabled = false;
      users.allow_sign_up = false;
    };
    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus"; uid = "prometheus"; type = "prometheus"; access = "proxy";
            url = "http://127.0.0.1:9090"; isDefault = true;
          }
          {
            name = "Loki"; uid = "loki"; type = "loki"; access = "proxy";
            # Loki listens on the LAN address only, not on loopback.
            url = "http://192.168.1.124:3100";
          }
        ];
      };
      dashboards.settings = {
        apiVersion = 1;
        providers = [{
          name = "edge";
          type = "file";
          folder = "Edge";
          disableDeletion = false;
          updateIntervalSeconds = 30;
          allowUiUpdates = true;
          options.path = ./dashboards;
        }];
      };
    };
  };

  # ---- Log aggregation for edge abuse monitoring (vessel-02 pushes here) ----
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      analytics.reporting_enabled = false;
      server = {
        http_listen_address = "192.168.1.124";
        http_listen_port = 3100;
        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = 9096;
      };
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
      };
      schema_config.configs = [{
        from = "2026-01-01";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index = {
          prefix = "index/";
          period = "24h";
        };
      }];
      limits_config = {
        retention_period = "30d";
        allow_structured_metadata = true;
        # The top-client-IP / top-path LogQL queries aggregate over many
        # per-IP series; the default limit of 500 rejects them.
        max_query_series = 10000;
      };
      compactor = {
        working_directory = "/var/lib/loki/compactor";
        retention_enabled = true;
        delete_request_store = "filesystem";
      };
    };
  };

  # Keep the observability stack from competing with Nextcloud/Plex (ADR-001).
  systemd.services.loki.serviceConfig = {
    MemoryMax = "1G";
    CPUWeight = 50;
  };

  services.home-assistant = {
    enable = true;

    extraComponents = [
      "default_config"
      "zha"
      "ffmpeg"
      "stream"
      "onvif"
      "mobile_app"
    ];

    config = {
      default_config = {};

      homeassistant = {
        name = "Home";
        time_zone = "Europe/Lisbon";
        internal_url = "http://192.168.1.124:8123";
        external_url = "https://ha.filipeom.dev";
      };

      http = {
        server_port = 8123;
        use_x_forwarded_for = true;
        # Only the edge (vessel-02) may set X-Forwarded-* headers.
        trusted_proxies = [ "192.168.1.111" ];
      };
    };
  };

  systemd.services.home-assistant.serviceConfig.MemoryMax = "2G";

  # mgmt
  # Restart NUT on its own if the driver stops serving data.
  my.nut-watchdog.enable = true;
  power.ups = {
    enable = true;
    mode = "netserver";
    ups.salicru = {
      driver = "nutdrv_qx";
      port = "auto";
      description = "Salicru SPS One 1100VA";
    };
    upsd.listen = [
      { address = "127.0.0.1"; }
      { address = "192.168.1.124"; }
    ];
    users.upsmon = {
      passwordFile = "/var/lib/nut/upsmon.password";
      upsmon = "primary";
    };
    upsmon = {
      monitor.salicru = {
        system = "salicru@127.0.0.1";
        user = "upsmon";
        type = "primary";
      };
      settings.FINALDELAY = 30;   # let the secondaries stop first
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 3000 3100 3493 8123 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
