{ lib, config, ... }:
with lib;
let
  cfg = config.services.lsd;
in
{
  options.services.lsd = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.lsd = {
      enable = true;
      enableAliases = false;
      colors = {
        user = 159;
        group = 231;
        permission = {
          # read = 183;
          # write = 212;
          # exec = 159;
          # exec-sticky = 159;
          # no-access = 210;
          read = 77; #limegreen
          write = 216; #orange
          exec = 204; #crimson
          exec-sticky = 163; #crimson
          no-access = 195; #lavender
          octal = 0;
          acl = 0;
          context = 0;
        };
        date = {
          # hour-old = 146;
          # day-old = 103;
          # older = 60;
          hour-old = 39; #lightseagreen
          day-old = 45; #darkcyan
          older = 117; #mediumturquoise
        };
        size = {
          # none = 60;
          # small = 120;
          # medium = 222;
          # large = 210;
          none = 195; #lavender
          small = 223; #burlywood
          medium = 215; #sandybrown
          large = 202; #orange
        };
        inode = {
          valid = 231;
          invalid = 210;
        };
        links = {
          valid = 9; # cyan # 159;
          invalid = 14; # red # 210;
        };
        tree-edge = 183;
      };
      settings = {
        indicators = false;

        # == Color ==
        # This has various color options. (Will be expanded in the future.)
        color = {
          # When to colorize the output.
          # When "classic" is set, this is set to "never".
          # Possible values: never, auto, always
          when = "auto";
        };

        # == Date ==
        # This specifies the date format for the date column. The freeform format
        # accepts an strftime like string.
        # When "classic" is set, this is set to "date".
        # Possible values: date, relative, +<date_format>
        # `date_format` will be a `strftime` formatted value. e.g. `date: '+%d %b %y %X'` will give you a date like this: 17 Jun 21 20:14:55
        date = "+%y/%m-%d %H:%M"; # "relative";


        # == Dereference ==
        # Whether to dereference symbolic links.
        # Possible values: false, true
        dereference = false;

        # == Classic ==
        # This is a shorthand to override some of the options to be backwards compatible
        # with `ls`. It affects the "color"->"when", "sorting"->"dir-grouping", "date"
        # and "icons"->"when" options.
        # Possible values: false, true
        classic = false;

        # == Icons ==
        icons = {
          # When to use icons.
          # When "classic" is set, this is set to "never".
          # Possible values: always, auto, never
          when = "auto"; #"always";
          separator = "  "; # double-space, first one gets consumed by nerdfont icon
          theme = "fancy";
        };

        # == Layout ==
        # Which layout to use. "oneline" might be a bit confusing here and should be
        # called "one-per-line". It might be changed in the future.
        # Possible values: grid, tree, oneline
        layout = "grid";


        # == Recursion ==
        recursion = {
          # Whether to enable recursion.
          # Possible values: false, true
          enabled = false;
          # How deep the recursion should go. This has to be a positive integer. Leave
          # it unspecified for (virtually) infinite.
          # depth: 3
        };

        # == Size ==
        # Specifies the format of the size column.
        # Possible values: default, short, bytes
        size = "default"; #"short";

        # == Sorting ==
        sorting = {
          # Specify what to sort by.
          # Possible values: extension, name, time, size, version
          column = "name";
          # Whether to reverse the sorting.
          # Possible values: false, true
          reverse = false;
          # Whether to group directories together and where.
          # When "classic" is set, this is set to "none".
          # Possible values: first, last, none
          dir-grouping = "first";
        };
        # == Blocks ==
        # This specifies the columns and their order when using the long and the tree
        # layout.
        # Possible values: permission, user, group, size, size_value, date, name, inode
        blocks = [
          "permission"
          "user"
          "group"
          "size"
          "date"
          "name"
        ];
        permission = "rwx";

        # == Hyperlink ==
        # Attach hyperlink to filenames
        # Possible values: always, auto, never
        hyperlink = "auto"; # "never";

        # == No Symlink ==
        # Whether to omit showing symlink targets
        # Possible values: false, true
        no-symlink = false;

        # == Symlink arrow ==
        # Specifies how the symlink arrow display, chars in both ascii and utf8
        symlink-arrow = "⇒";

        # == Total size ==
        # Whether to display the total size of directories.
        # Possible values: false, true
        total-size = false;

        # == Truncate owner ==
        # How to truncate the username and group names for a file if they exceed a certain
        # number of characters.
        truncate-owner = {
          # Number of characters to keep. By default, no truncation is done (empty value).
          after = 10;
          # String to be appended to a name if truncated.
          marker = "*";
        };
      };
    };

    home.shellAliases = {
      ls = "lsd";
      l = "ls -l";
      la = "ls -a'";
      lla = "ls -la";
      lt = "ls --tree";
    };
  };
}
