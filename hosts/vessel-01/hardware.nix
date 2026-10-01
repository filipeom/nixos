{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  hardware.i2c.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;

    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  swapDevices = [
    { device = "/swapfile"; size = 32768; }
  ];

  boot.resumeDevice = "/dev/sda2";
  boot.kernelParams = [ "resume_offset=229838848" ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;
}
