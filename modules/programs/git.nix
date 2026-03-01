{ lib, pkgs, config, ... }:
{
  enable = true;
  settings = {
    user.name = "Filipe Marques";
    user.email = "filipe.s.marques@tecnico.ulisboa.pt";
    credential.helper = "store";
  };
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
}
