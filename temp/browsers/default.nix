{ options, lib, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.browsers;
in
{
  imports = [
    ./chrome-based-browser
    ./firefox-based-browser
  ];

  options.${namespace}.programs.graphical.browsers = with types; {
    enable = mkBoolOpt false "Whether or not to enable a browser.";
    # browsers = mkOpt (listOf (str enum [ "firefox" "firefox-devedition" "firefox-esr" "librewolf" "floorp" "waterfox" "chromium" "ungoogled-chromium" "google-chrome" "brave" "vivaldi" "opera" null ])) [ ] "Browsers you want to install.";
    browsers = mkOpt (listOf (strMatching (builtins.elem [ "firefox" "firefox-devedition" "firefox-esr" "librewolf" "floorp" "waterfox" "chromium" "ungoogled-chromium" "google-chrome" "brave" "vivaldi" "opera" null ]))) [ ] "Browsers you want to install.";
  };
}
