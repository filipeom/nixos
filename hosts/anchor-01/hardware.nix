{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  swapDevices = [
    { device = "/swapfile"; size = 16384; }
  ];

  boot.supportedFilesystems = [ "zfs" ];

  boot.zfs.extraPools = [ "zpool" "mediapool" "cachepool" ];
  boot.zfs.forceImportRoot = false;

  services.zfs.autoScrub.enable = true;

  networking.hostId = "2670c489";
}
