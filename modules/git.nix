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
    key = "74A869792DE9DF80!";
    signByDefault = true;
  };
  extraConfig = {
    credential.helper = "store";
  };
}
