# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.bluetooth.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "vessel-01"; # Define your hostname.
  networking.useDHCP = false;
  networking.interfaces.eno1 = {
    ipv4.addresses = [{
      address = "192.168.1.110";
      prefixLength = 24;
    }];
    ipv6.addresses = [{
      address = "fd00::110";
      prefixLength = 64;
    }];
  };
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.extraHosts = ''
    192.168.1.124   cloud.filipeom.dev
  '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Disable networking (static ip above)
  networking.networkmanager.enable = true;

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
  services.xserver.videoDrivers = [ "modesetting" ];
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
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcWHhvPTxv1epTRNYeoU0XMHPDNmDbn1Vuv2JTUdncZ filipe"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "filipe" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
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
    firefox
    pavucontrol
    playerctl
    pulseaudio
    bluez
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # List services that you want to enable:

  # Enable display manager
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      lang = "pt";
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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

  # Use PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;   # allows legacy ALSA apps
    pulse.enable = true;  # PulseAudio compatibility
    jack.enable = false;  # optional
  };

  # Enable Bluetooth daemon
  services.blueman.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    glib
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
