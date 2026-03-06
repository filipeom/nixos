# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "vessel-01"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  virtualisation.docker.enable = false;

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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcWHhvPTxv1epTRNYeoU0XMHPDNmDbn1Vuv2JTUdncZ filipe"
    ];
  };

  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  services.github-runners.vessel-runner = {
    enable = true;
    url = "https://github.com/formalsec"; # or your org
    tokenFile = "/var/lib/github-runner/token";    # Create this file manually once
    user = "root";
    serviceOverrides.StateDirectory = [
      "github-runner/vessel-runner" # module default
      "github-runner-work/vessel-runner"
    ];
    workDir = "/var/lib/github-runner-work/vessel-runner";
    nodeRuntimes = [ "node20" "node24" ];
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
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
