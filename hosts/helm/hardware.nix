{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  hardware.i2c.enable = true;
  hardware.bluetooth.enable = true;

  # Swap for hibernation (S4)
  swapDevices = [
    { device = "/swapfile"; size = 24576; }
  ];

  # Resume from swapfile for hibernation
  boot.resumeDevice = "/dev/nvme0n1p2";
  boot.kernelParams = [ "resume_offset=33781760" ];

  # Power management for battery life
  services.tlp = {
    enable = true;
    settings = {
      PLATFORM_PROFILE_ON_BAT = "low-power";
      CPU_SCALING_MAX_FREQ_ON_BAT = 2400000;
      CPU_SCALING_MAX_FREQ_ON_AC = 4200000;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  my.power-tune.enable = true;

  # Lid switch behaviour is handled by the `lidctl` daemon (see
  # modules/services/hyprland.nix). logind must not suspend or fight it.
  services.logind.settings.Login.HandleLidSwitch = "ignore";
}
