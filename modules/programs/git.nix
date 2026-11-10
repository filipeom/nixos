{ lib, pkgs, config, ... }:
{
  programs.git = {
    settings = {
      user.name = "Filipe Marques";
      user.email = "filipe.s.marques@tecnico.ulisboa.pt";
      credential.helper = "store";
    };
    ignores = [
      ".direnv/"
      ".envrc"
      "_opam/"
      ".claude"
    ];
  };
}
