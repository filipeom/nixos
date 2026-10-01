{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.runSize = "50%";
  boot.kernelModules = [ "nct6775" ];
  boot.kernelParams = [
    "zswap.enabled=1" "zswap.compressor=zstd"
    "zswap.zpool=zsmalloc" "zswap.max_pool_percent=25"
  ];

  swapDevices = [
    { device = "/swapfile"; size = 32768; }
  ];
}
