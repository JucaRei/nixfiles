{ pkgs, lib, params, ... }:
let
  ifDefault = lib.mkIf (params.browser == "chromium");
in
{
  environment.systemPackages = with pkgs.unstable; [
    chromium
  ];

  programs = {
    chromium = {
      enable = true;
      extensions = [
        "hdokiejnpimakedhajhdlcegeplioahd" # LastPass
      ];
      extraOpts = {
        "AutofillAddressEnabled" = false;
        "AutofillCreditCardEnabled" = false;
        "BuiltInDnsClientEnabled" = false;
        "​DeviceMetricsReportingEnabled" = true;
        "​ReportDeviceCrashReportInfo" = false;
        "PasswordManagerEnabled" = false;
        "​SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "en-GB"
          "en-US"
        ];
        "VoiceInteractionHotwordEnabled" = false;
      };
    };
  };
  xdg = {
    mime.enable = ifDefault true;
    mimeApps = {
      enable = ifDefault true;
      defaultApplications = ifDefault (import ./default-browser.nix "chromium");
    };
  };
}
