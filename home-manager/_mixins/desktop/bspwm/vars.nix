{ pkgs, config }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  chromium-browser = import ../../apps/browser/chrome/ungoogled-chromium.nix { inherit pkgs config; };
  nerdPatched = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "Iosevka" "JetBrainsMono" ]; })
  ];
in
{
  # font-0 = "Iosevka Nerd Font:size=10;3"
  # font-1 = "Iosevka Nerd Font:size=12;3"
  # font-2 = "google\-mdi:size=12;3"
  # font-3 = "Iosevka:style=bold:size=12;3"
  # font-4 = "Iosevka Nerd Font:size=18;4"
  # font-5 = "Iosevka:style=bold:size=18;4"

  ##################
  ### Everforest ###
  ##################

  polybar-0 = {
    package = pkgs.maple-mono;
    name = "Maple Mono";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "Maple Mono:style=Regular:size=11";
    offset = 2; # Offset for Polybar.
  };

  polybar-1 = {
    package = pkgs.font-awesome;
    name = "Font Awesome 6 Free Solid";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "Font Awesome 6 Free Solid:size=11";
    offset = 3; # Offset for Polybar.
  };

  polybar-2 = {
    package = pkgs.material-design-icons;
    name = "Material Design Icons Desktop";
    ftname = "Material Design Icons Desktop:size=12";
    offset = 3; # Offset for Polybar.
  };

  polybar-3 = {
    package = pkgs.material-design-icons;
    name = "Material Design Icons Desktop";
    ftname = "material-design-icons:size=12";
    offset = 3; # Offset for Polybar.
  };

  polybar-4 = {
    package = pkgs.meslo-lgs-nf;
    name = "MesloLGS NF";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "MesloLGS NF:style=Regular:size=15";
    offset = 4; # Offset for Polybar.
  };

  polybar-5 = {
    package = pkgs.maple-mono-SC-NF;
    name = "Maple Mono SC NF";
    ftname = "Maple Mono SC NF:size=11";
    offset = 2; # Offset for Polybar.
  };

  polybar-6 = {
    package = pkgs.unstable.sarasa-gothic;
    name = "Sarasa Mono CL Nerd Font";
    ftname = "Sarasa Mono CL Nerd Font:size2";
    offset = 4;
  };

  ##############
  ### Batman ###
  ##############

  batman-0 = {
    package = nerdPatched;
    name = "Iosevka Nerd Font";
    ftname = "Iosevka Nerd Font:style=Bold:size=8";
    offset = 2;
  };

  batman-1 = {
    package = nerdPatched;
    name = "Iosevka Nerd Font";
    ftname = "Iosevka Nerd Font:style=Medium:size=13";
    offset = 2;
  };

  batman-2 = {
    package = pkgs.material-icons;
    name = "Material Icons";
    ftname = "Material Icons:style=Bold:size=10";
    offset = 4;
  };

  batman-3 = {
    package = nerdPatched;
    name = "JetBrainsMono Nerd Font";
    ftname = "JetBrainsMono Nerd Font:style=Medium:size=11";
    offset = 3;
  };

  batman-4 = {
    package = pkgs.material-design-icons;
    name = "Material Design Icons Desktop";
    ftname = "Material Design Icons Desktop:style=Design-Iconic-Font:size=8";
    offset = 2;
  };

  batman-5 = {
    package = pkgs.maple-mono-SC-NF;
    name = "Maple Mono SC NF";
    ftname = "Maple Mono SC NF:style=Regular:size=15";
    offset = 4; # Offset for Polybar.
  };

  batman-6 = {
    package = nerdPatched;
    name = "JetBrainsMono Nerd Font";
    ftname = "JetBrainsMono Nerd Font:style=Medium:size=8";
    offset = 2;
  };

  mod = "super"; # alt
  # alacritty-custom = nixgl pkgs.alacritty;
  alacritty-custom = nixgl (import ../../apps/file-managers/thunar.nix { inherit pkgs; });
}
