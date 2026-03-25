{ lib, pkgs, config, ... }:
{
  programs.kitty = {
    settings = {
      font_family = lib.mkDefault "JetBrainsMono Nerd Font";
      bold_font = lib.mkDefault "auto";
      italic_font = lib.mkDefault "auto";
      bold_italic_font = lib.mkDefault "auto";

      font_size = lib.mkDefault 14;
      force_ltr = lib.mkDefault "no";
      disable_ligatures = lib.mkDefault "never";

      box_drawing_scale = lib.mkDefault "0.001, 1, 1.5, 2";
      text_composition_strategy = lib.mkDefault "1.8 5";
      text_fg_override_threshold = lib.mkDefault 0;
    };

    extraConfig = lib.mkDefault ''
      include ${../../dotfiles/kitty/dayfox.conf}
    '';
  };
}
