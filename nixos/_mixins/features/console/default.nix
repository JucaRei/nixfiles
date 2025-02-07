{ config, desktop, hostname, isInstall, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  kmsconFontSize = {
    rocinante = "24";
    nitro = "20";
    anubis = "22";
  };
  kmsconExtraConfig = (
    if (builtins.hasAttr hostname kmsconFontSize) then
      ''font-size=${kmsconFontSize.${hostname}} ''
    else
      ''font-size=14''
  )
  + ''
    no-drm
    no-switchvt
    grab-scroll-up=
    grab-scroll-down=
    palette=custom
    palette-black=69,71,90
    palette-red=243,139,168
    palette-green=166,227,161
    palette-yellow=249,226,175
    palette-blue=137,180,250
    palette-magenta=245,194,231
    palette-cyan=148,226,213
    palette-light-grey=127,132,156
    palette-dark-grey=88,91,112
    palette-light-red=243,139,168
    palette-light-green=166,227,161
    palette-light-yellow=249,226,175
    palette-light-blue=137,180,250
    palette-light-magenta=245,194,231
    palette-light-cyan=148,226,213
    palette-white=205,214,244
    palette-foreground=166,173,200
    palette-background=30,30,46
    sb-size=10240
  '';
in
{
  boot = {
    # Catppuccin theme
    kernelParams = [
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    ];
  };

  catppuccin = {
    accent = "blue";
    flavor = "mocha";
  };

  console = {
    keyMap = if (hostname == "nitro") || (hostname == "scrubber") then "br-abnt" else "us";

    earlySetup = true;
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    # font = "ter-powerline-v32n";
    packages = with pkgs; [
      tamzen
      # terminus_font
      # powerline-fonts
    ];
  };

  services = {
    kmscon = lib.mkIf isInstall {
      enable = !config.boot.plymouth.enable;
      extraOptions = "--gpus primary";
      hwRender = if (desktop == null) then true else false;
      fonts = [
        {
          name = "FiraCode Nerd Font Mono";
          package = pkgs.nerdfonts.override {
            fonts = [
              "FiraCode"
              "NerdFontsSymbolsOnly"
            ];
          };
        }
      ];
      extraConfig = kmsconExtraConfig;
    };
    getty = mkIf isInstall {
      greetingLine = "\\l";
      helpLine = ''
        Type `i' to print system information.

            .     .       .  .   . .   .   . .    +  .
              .     .  :     .    .. :. .___---------___.
                   .  .   .    .  :.:. _".^ .^ ^.  '.. :"-_. .
                .  :       .  .  .:../:            . .^  :.:\.
                    .   . :: +. :.:/: .   .    .        . . .:\
             .  :    .     . _ :::/:               .  ^ .  . .:\
              .. . .   . - : :.:./.                        .  .:\
              .      .     . :..|:                    .  .  ^. .:|
                .       . : : ..||        .                . . !:|
              .     . . . ::. ::\(                           . :)/
             .   .     : . : .:.|. ######              .#######::|
              :.. .  :-  : .:  ::|.#######           ..########:|
             .  .  .  ..  .  .. :\ ########          :######## :/
              .        .+ :: : -.:\ ########       . ########.:/
                .  .+   . . . . :.:\. #######       #######..:/
                  :: . . . . ::.:..:.\           .   .   ..:/
               .   .   .  .. :  -::::.\.       | |     . .:/
                  .  :  .  .  .-:.":.::.\             ..:/
             .      -.   . . . .: .:::.:.\.           .:/
            .   .   .  :      : ....::_:..:\   ___.  :/
               .   .  .   .:. .. .  .: :.:.:\       :/
                 +   .   .   : . ::. :.:. .:.|\  .:/|
                 .         +   .  .  ...:: ..|  --.:|
            .      . . .   .  .  . ... :..:.."(  ..)"
             .   .       .      :  .   .: ::/  .  .::\
      '';
    };
  };
}
