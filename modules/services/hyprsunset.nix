{ pkgs, lib, ... }:
{
  services.hyprsunset = {
    settings = {
      max-gamma = lib.mkDefault 150;
      profile = lib.mkDefault [
        {
          time = "7:00";
          temperature = 6000;
          gamma = 1.0;
        }
        {
          time = "10:00";
          temperature = 5500;
          gamma = 0.95;
        }
        {
          time = "18:55";
          temperature = 4500;
          gamma = 0.8;
        }
      ];
    };
  };
}
