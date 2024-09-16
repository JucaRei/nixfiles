{ hostname, isInstall, lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  xkblayout = if (hostname == "soyo" || hostname == "nitro") then "br" else "us";
  kmsconFontSize = {
    soyo = "24";
    nitro = "18";
    air = "22";
  };
  kmsconExtraConfig =
    (
      if (builtins.hasAttr hostname kmsconFontSize) then
        ''font-size=${kmsconFontSize.${hostname}} ''
      else
        ''font-size=14''
    )
    + ''
      palette=custom
      palette-foreground=30, 30, 46
      palette-foreground=20, 214, 244

      xkb-layout = ${xkblayout}
    '';
  cfg = config.sys.console;
in
{
  options.sys.console = {
    enable = mkEnableOption "Wheater enable console configuration." // { default = isInstall; };
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

    catppuccin = {
      accent = "blue";
      flavor = "mocha";
    };

    console = {
      earlySetup = true;
      font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
      packages = with pkgs; [ tamzen ];
    };

    services = {
      kmscon = mkIf isInstall {
        enable = true;
        hwRender = false;
        extraOptions = "--gpus primary";
        fonts = [{
          name = "FiraCode Nerd Font Mono";
          package = pkgs.nerdfonts.override {
            fonts = [
              "FiraCode"
              "NerdFontsSymbolsOnly"
            ];
          };
        }];
        extraConfig = kmsconExtraConfig;
      };
    };
  };
}
