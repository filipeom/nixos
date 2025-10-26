{ lib, pkgs, config, ... }:
{
  enable = true;
  userName = "Filipe Marques";
  userEmail = "filipe.s.marques@tecnico.ulisboa.pt";
  ignores = [
    ".files"
    ".direnv/"
    ".envrc"
  ];
  signing = {
    format = "openpgp";
    key = "88A27E44DCAF7B34";
    signByDefault = true;
  };
  extraConfig = {
    credential.helper = "store";
  };
}
