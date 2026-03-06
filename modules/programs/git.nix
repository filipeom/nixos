{ lib, pkgs, config, ... }:
{
  programs.git = {
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
  };
}
