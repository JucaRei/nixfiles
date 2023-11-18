{ pkgs, config, lib, params, ... }:
# let
# ifDefault = lib.mkIf (builtins.elem params.browser [ "chromium" ]);
# in
{
  programs = {
    chromium = {
      enable = true;
      package = with pkgs.unstable; [ chromium ];
      extensions = [
        "hdokiejnpimakedhajhdlcegeplioahd" # LastPass
        "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
        "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
        "edlifbnjlicfpckhgjhflgkeeibhhcii" # Screenshot Tool
      ];
      extraOpts = {
        "AutofillAddressEnabled" = false;
        "AutofillCreditCardEnabled" = false;
        "BuiltInDnsClientEnabled" = false;
        "DeviceMetricsReportingEnabled" = true;
        "ReportDeviceCrashReportInfo" = false;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [ "pt-BR" "en-GB" "en-US" ];
        "VoiceInteractionHotwordEnabled" = false;
      };
    };
  };
  # xdg = {
  # mime.enable = ifDefault true;
  # mimeApps = {
  # enable = ifDefault true;
  # defaultApplications = ifDefault (import ./default-browser.nix "chromium");
  # };
  # };
}
