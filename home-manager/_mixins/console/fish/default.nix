{ pkgs, lib, config, ... }:
with lib;
let
  inherit (pkgs.stdenv) isLinux;
  cfg = config.services.fish;
in
{
  imports = [
    ../powerline-go.nix
    ../zoxide.nix
  ];

  options.services.fish = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    programs = {
      fish = {
        enable = true;
        shellAliases = {
          banner = lib.mkIf isLinux "${pkgs.figlet}/bin/figlet";
          banner-color =
            lib.mkIf isLinux
              "${pkgs.figlet}/bin/figlet $argv | ${pkgs.dotacat}/bin/dotacat";
          brg = "${pkgs.bat-extras.batgrep}/bin/batgrep";
          cat = "${pkgs.bat}/bin/bat --paging=never";
          dadjoke = ''
            ${pkgs.curlMinimal}/bin/curl --header "Accept: text/plain" https://icanhazdadjoke.com/'';
          dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
          neofetch = "${pkgs.fastfetch}/bin/fastfetch";
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
      };
    };

    home.file = {
      "${config.xdg.configHome}/fish/functions/build-home.fish".text =
        builtins.readFile ../../config/fish/build-home.fish;
      "${config.xdg.configHome}/fish/functions/switch-home.fish".text =
        builtins.readFile ../../config/fish/switch-home.fish;
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
