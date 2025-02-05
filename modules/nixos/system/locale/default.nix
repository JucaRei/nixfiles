{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  hostname = config.${namespace}.system.modules.hosts;
  cfg = config.${namespace}.system.locale;
in
{
  options.${namespace}.system.locale = with types; {
    enable = mkBoolOpt false "Whether or not to manage locale settings.";
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

    i18n = {
      defaultLocale = "en_US.utf8";
      extraLocaleSettings = {
        #LC_CTYPE =  "pt_BR.UTF-8"; # Fix ç in us-intl.
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
      };
    };

    supportedLocales = [
      "pt_BR.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];

    console = {
      keyMap = if (hostname == "nitro") || (hostname == "scrubber") then "br-abnt" else "us";
      earlySetup = true;
      # font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
      font = "ter-powerline-v26n";
      packages = with pkgs; [
        # tamzen
        terminus_font
        powerline-fonts
      ];
    };

    services = {
      # kmscon = lib.mkIf isInstall {
      #   enable = !config.boot.plymouth.enable;
      #   extraOptions = "--gpus primary";
      #   hwRender = if (desktop == null) then true else false;
      #   extraConfig = kmsconExtraConfig;
      # };
      # getty = mkIf isInstall {
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
