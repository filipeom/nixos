{ lib, pkgs, config, ... }:
{
  programs.ncspot = {
    settings = {
      use_nerdfont = true;
      notify = true;

      gapless = true;
      bitrate = 320;

      audio_cache = true;
      audio_cache_size = 512;
    };
  };
}
