{ pkgs }: {
  # font-0 = "Iosevka Nerd Font:size=10;3"
  # font-1 = "Iosevka Nerd Font:size=12;3"
  # font-2 = "google\-mdi:size=12;3"
  # font-3 = "Iosevka:style=bold:size=12;3"
  # font-4 = "Iosevka Nerd Font:size=18;4"
  # font-5 = "Iosevka:style=bold:size=18;4"

  polybar-0 = {
    package = pkgs.iosevka;
    name = "Iosevka Nerd Font";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "Iosevka:style=Regular:size=10";
    offset = 3; # Offset for Polybar.
  };

  polybar-1 = {
    package = pkgs.iosevka;
    name = "Iosevka Nerd Font";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "Iosevka:style=Regular:size=10";
    offset = 3; # Offset for Polybar.
  };

  polybar-2 = {
    package = pkgs.material-design-icons;
    name = "google";
    ftname = "google\-mdi:size=12";
    offset = 3; # Offset for Polybar.
  };

  polybar-3 = {
    package = pkgs.iosevka;
    name = "Iosevka";
    ftname = "Iosevka:style=bold:size=12";
    offset = 3; # Offset for Polybar.
  };

  polybar-4 = {
    package = pkgs.iosevka;
    name = "Iosevka Nerd Font";
    # ftname = "Iosevka Nerd Font:style=Regular:size=10";
    ftname = "Iosevka:style=Regular:size=18";
    offset = 4; # Offset for Polybar.
  };

  polybar-5 = {
    package = pkgs.iosevka;
    name = "Iosevka";
    ftname = "Iosevka:style=bold:size=18";
    offset = 4; # Offset for Polybar.
  };

  polybar-6 = {
    package = pkgs.material-design-icons;
    name = "Material Design Icons";
    ftname = "Material Design Icons:style=Bold:size18";
    offset = 4;
  };
}
