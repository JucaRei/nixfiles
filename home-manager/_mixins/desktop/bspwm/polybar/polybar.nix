{ pkgs, ... }: {
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybarFull;
      config = {
        "colors" = {
          background = "#1a1b26";
          background-alt = "#24283b";
          foreground = "#c0caf5";
          primary = "#e0af68";
          secondary = "#9ece6a";
          alert = "#db4b4b";
          disabled = "#414868";
          blue = "#7aa2f7";
        };
        "bar/bar" = {
          width = "1884px";
          height = "33pt";
          radius = 6;
          fixed-center = true;
          dpi = 96;
          offset-x = 18;
          offset-y = 10;

          background = "#1a1b26";
          foreground = "#c0caf5";

          line-size = "3pt";

          border-size = "7pt";
          border-color = "#1a1b26";
          border-radius = 15;

          padding-left = 0;
          padding-right = 1;

          font-0 = "Sofia Pro:style=Bold:size=20;3";
          font-1 = "Material Design Icons Desktop:size=16;3";
          font-2 = "Material Design Icons Desktop:size=20;5";
          font-3 = "JetBrainsMono Nerd Font:size=27;6";
          font-4 = "JetBrainsMono Nerd Font:size=17;5";
          font-5 = "JetBrainsMono Nerd Font:size=16;4";
          font-6 = "Material Design Icons Desktop:size=16;4";
          font-7 = "Sofia Pro:style=Bold:size=18;0";
          font-8 = "Material Design Icons Desktop:size=18;4";
          font-9 = "Feather:style=Bold:size=18;6";
          font-10 = "Material Design Icons Desktop:size=20:style=bold;5";
          font-11 = "Sofia Pro:style=Bold:size=14;3";
          font-12 = "Material Design Icons Desktop:size=14;3";
          font-13 = "JetBrainsMono Nerd Font:size=14;4";
          font-14 = "Grid Styles:size=18;4";

          modules-left = "launcher left1 xworkspaces right1 seperator left3 updates spotify gamemode right3";
          modules-center = "date";
          modules-right = "bspwm tray left2 battery network bluetooth microphone pulseaudio right2 github powermenu";

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };
      };
    };
  };
}
