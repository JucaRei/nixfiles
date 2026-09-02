{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.system.console.options;
in
{
  options = {
    system.console.options = {
      enable = mkEnableOption "Enable console support";
    };
  };

  config = mkIf cfg.enable {
    boot = {
      # Catppuccin theme
      kernelParams = [
        "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
        "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
        "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
      ];
    };

    console = {
      enable = true;
      useXkbConfig = true;
      # keyMap = mkIf (hostname == "nitro" || hostname == "scrubber") "br-abnt";
      earlySetup = false;
      font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
      # font = "ter-powerline-v26n";
      packages = with pkgs; [
        tamzen
        # terminus_font
        # powerline-fonts
      ];
    };

    services = {
      getty = {
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
  };
}
