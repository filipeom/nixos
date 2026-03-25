{ lib, pkgs, config, ... }:
{
  programs.git = {
    settings = {
      user.name = lib.mkDefault "Filipe Marques";
      user.email = lib.mkDefault "filipe.s.marques@tecnico.ulisboa.pt";
      credential.helper = lib.mkDefault "store";
    };
    ignores = lib.mkDefault [
      ".files"
      ".direnv/"
      ".envrc"
    ];
  };
}
