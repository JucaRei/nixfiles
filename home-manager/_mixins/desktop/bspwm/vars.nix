{ pkgs, config, hostname }:
let
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  chromium-browser = import ../../apps/browser/chrome/ungoogled-chromium.nix { inherit pkgs config; };
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  nerdPatched = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
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

  everforest-0 = {
    package = pkgs.maple-mono;
    name = "Maple Mono";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "Maple Mono:style=Regular:size=11";
    offset = 2; # Offset for Polybar.
  };

  everforest-1 = {
    package = pkgs.font-awesome;
    name = "Font Awesome 6 Free Solid";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "Font Awesome 6 Free Solid:size=11";
    offset = 3; # Offset for Polybar.
  };

  everforest-2 = {
    package = pkgs.material-design-icons;
    name = "Material Design Icons Desktop";
    ftname = "Material Design Icons Desktop:size=12";
    offset = 3; # Offset for Polybar.
  };

  everforest-3 = {
    package = pkgs.material-design-icons;
    name = "Material Design Icons Desktop";
    ftname = "material-design-icons:size=12";
    offset = 3; # Offset for Polybar.
  };

  everforest-4 = {
    package = pkgs.meslo-lgs-nf;
    name = "MesloLGS NF";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "MesloLGS NF:style=Regular:size=15";
    offset = 4; # Offset for Polybar.
  };

  everforest-5 = {
    package = pkgs.maple-mono-SC-NF;
    name = "Maple Mono SC NF";
    ftname = "Maple Mono SC NF:size=11";
    offset = 2; # Offset for Polybar.
  };

  everforest-6 = {
    package = pkgs.unstable.sarasa-gothic;
    name = "Sarasa Mono CL Nerd Font";
    ftname = "Sarasa Mono CL Nerd Font:size=2";
    offset = 4;
  };

  mod = if (hostname == "nitro") then "alt" else "super"; # alt
  modAlt = if (hostname == "nitro") then "super" else "alt"; # alt
  # alacritty-custom = if (hostname != "nitro") then (nixgl config.programs.alacritty.package) else (config.programs.alacritty.package);
  alacritty-custom = if (isGeneric) then (nixgl config.programs.alacritty.package) else (config.programs.alacritty.package);
  picom-custom = "${config.services.picom.package}/bin/picom";
  filemanager = "thunar";
  browser = if (hostname == "nitro") then "brave" else "thorium";
}
