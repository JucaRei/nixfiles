{ pkgs, lib, config, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkOption types mkIf;
  cfg = config.custom.console.fish;
in
{
  imports = [
    # ../starship.nix
  ];

  options.custom.console.fish = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs = {
      fish = {
        enable = true;
        shellAliases = {
          banner = lib.mkIf isLinux "${pkgs.figlet}/bin/figlet";
          banner-color =
            lib.mkIf isLinux
              "${pkgs.figlet}/bin/figlet $argv | ${pkgs.dotacat}/bin/dotacat";
          brg = "${pkgs.bat-extras.batgrep}/bin/batgrep";
          dadjoke = ''
            ${pkgs.curlMinimal}/bin/curl --header "Accept: text/plain" https://icanhazdadjoke.com/'';
          dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
          # neofetch = "${pkgs.fastfetch}/bin/fastfetch";
          glow = "${pkgs.glow}/bin/glow --pager";
          hr = ''${pkgs.hr}/bin/hr "─━"'';
          # ip = "${pkgs.iproute2}/bin/ip --color --brief";
          # less = "${pkgs.bat}/bin/bat";
          lolcat = "${pkgs.dotacat}/bin/dotacat";
          make-lima-builder = "lima-create builder";
          make-lima-default = "lima-create default";
          moon = "${pkgs.curlMinimal}/bin/curl -s wttr.in/Moon";
          # more = "${pkgs.bat}/bin/bat";
          checkip = "${pkgs.curlMinimal}/bin/curl -s ifconfig.me/ip";
          parrot = "${pkgs.terminal-parrot}/bin/terminal-parrot -delay 50 -loops 7";
          ruler = ''${pkgs.hr}/bin/hr "╭─³⁴⁵⁶⁷⁸─╮"'';
          screenfetch = "${pkgs.fastfetch}/bin/fastfetch";
          speedtest = "${pkgs.speedtest-go}/bin/speedtest-go";
          store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
          top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
          # tree = "${pkgs.eza}/bin/eza --tree";
          wormhole = "${pkgs.wormhole-william}/bin/wormhole-william";
          weather = "${pkgs.wthrr}/bin/wthrr auto -u f,24h,c,mph -f d,w";
          weather-home = "${pkgs.wthrr}/bin/wthrr basingstoke -u f,24h,c,mph -f d,w";
        };
        functions = {
          greeting = ''
            echo
            echo -e (uname -ro | awk '{print " \\\\e[1mOS: \\\\e[0;32m"$0"\\\\e[0m"}')
            echo -e (uptime | cut -d , -f 1 | sed -E 's/.*up +//' | awk '{print " \\\\e[1mUptime: \\\\e[0;32m"$0"\\\\e[0m"}')
            echo -e (hostname | awk '{print " \\\\e[1mHostname: \\\\e[0;32m"$0"\\\\e[0m"}')
            echo -e " \\e[1mDisk usage:\\e[0m"
            # echo
            echo -ne (\
              df -l -h | grep -E 'boot' | \
              awk '{printf "\\\\t%s\\\\t%4s / %4s  %s\\\\n\n", $6, $3, $2, $5}' | \
              sed -e 's/^\(.*\([8][5-9]\|[9][0-9]\)%.*\)$/\\\\e[0;31m\1\\\\e[0m/' -e 's/^\(.*\([7][5-9]\|[8][0-4]\)%.*\)$/\\\\e[0;33m\1\\\\e[0m/' | \
              paste -sd '''\
            )
            echo

            echo -e " \\e[1mNetwork:\\e[0m"
            # echo
            # http://tdt.rocks/linux_network_interface_naming.html
            echo -ne (\
              ip addr show up scope global | \
                grep -E ': <|inet' | \
                sed \
                  -e 's/^[[:digit:]]\+: //' \
                  -e 's/: <.*//' \
                  -e 's/.*inet[[:digit:]]* //' \
                  -e 's/\/.*//'| \
                awk 'BEGIN {i=""} /\.|:/ {print i" "$0"\\\n"; next} // {i = $0}' | \
                sort | \
                column -t -R1 | \
                # # public addresses are underlined for visibility \
                # sed 's/ \([^ ]\+\)$/ \\\e[4m\1/' | \
                # private addresses are not \
                sed 's/m\(\(10\.\|172\.\(1[6-9]\|2[0-9]\|3[01]\)\|192\.168\.\).*\)/m\\\e[24m\1/' | \
                # unknown interfaces are cyan \
                sed 's/^\( *[^ ]\+\)/\\\e[36m\1/' | \
                # ethernet interfaces are normal \
                sed 's/\(\(en\|em\|eth\)[^ ]* .*\)/\\\e[39m\1/' | \
                # wireless interfaces are purple \
                sed 's/\(wl[^ ]* .*\)/\\\e[35m\1/' | \
                # wwan interfaces are yellow \
                sed 's/\(ww[^ ]* .*\).*/\\\e[33m\1/' | \
                sed 's/$/\\\e[0m/' | \
                sed 's/^/\t/' \
              )
            if [ -f ./TODO.txt ]
              set TODO (cat ./TODO.txt)
            else if [ -f ~/TODO.txt ]
              set TODO (cat ~/TODO.txt)
            end
            if [ "$TODO" != "" ]
              set_color normal
              echo -e "\n \\e[1mTODO:\\e[0m"
              for LINE in $TODO
                set_color green
                echo -e "\t$LINE"
              end
            end
          '';
          fish_greeting = ''
            set fishes (pidof fish | wc -w)
            if test $fishes -eq "1"
              greeting
            end
          '';
        };
      };
    };

    home.file = {
      # "${config.xdg.configHome}/fish/functions/build-home.fish".text =
      # builtins.readFile ../../config/fish/build-home.fish;
      # "${config.xdg.configHome}/fish/functions/switch-home.fish".text =
      # builtins.readFile ../../config/fish/switch-home.fish;
      "${config.xdg.configHome}/fish/functions/help.fish".text =
        builtins.readFile ../../config/fish/help.fish;
      "${config.xdg.configHome}/fish/functions/h.fish".text =
        builtins.readFile ../../config/fish/h.fish;
      "${config.xdg.configHome}/fish/functions/lima-create.fish".text =
        builtins.readFile ../../config/fish/lima-create.fish;
      "${config.xdg.configHome}/fish/functions/gpg-restore.fish".text =
        builtins.readFile ../../config/fish/gpg-restore.fish;
      "${config.xdg.configHome}/fish/functions/get-nix-hash.fish".text =
        builtins.readFile ../../config/fish/get-nix-hash.fish;
    };
  };
}
