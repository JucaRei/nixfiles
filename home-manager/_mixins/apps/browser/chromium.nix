# { pkgs, config, lib, params, ... }:
# let
# ifDefault = lib.mkIf (builtins.elem params.browser [ "chromium" ]);
# in
# {
# programs = {
#   chromium = {
#     enable = true;
#     package = with pkgs.unstable; [ chromium ];
#     extensions = [
#       "hdokiejnpimakedhajhdlcegeplioahd" # LastPass
#       "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
#       "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
#       "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
#       "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
#       "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
#       "edlifbnjlicfpckhgjhflgkeeibhhcii" # Screenshot Tool
#     ];
#     extraOpts = {
#       "AutofillAddressEnabled" = false;
#       "AutofillCreditCardEnabled" = false;
#       "BuiltInDnsClientEnabled" = false;
#       "DeviceMetricsReportingEnabled" = true;
#       "ReportDeviceCrashReportInfo" = false;
#       "PasswordManagerEnabled" = false;
#       "SpellcheckEnabled" = true;
#       "SpellcheckLanguage" = [ "pt-BR" "en-GB" "en-US" ];
#       "VoiceInteractionHotwordEnabled" = false;
#     };
#   };
# };
# xdg = {
# mime.enable = ifDefault true;
# mimeApps = {
# enable = ifDefault true;
# defaultApplications = ifDefault (import ./default-browser.nix "chromium");
# };
# };

# }

{ config
, options
, lib
, pkgs
, ...
}:
let
  inherit (builtins) toString;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
in
{
  options.modules.desktop.browsers.chromium =
    let
      inherit (lib.options) mkEnableOption;
    in
    { enable = mkEnableOption "Google-free chromium"; };

  config = mkIf config.modules.desktop.browsers.chromium.enable {
    home.packages =
      let
        inherit (pkgs) makeDesktopItem ungoogled-chromium;
      in
      [
        (makeDesktopItem {
          name = "ungoogled-private";
          desktopName = "Ungoogled Web Browser (Private)";
          genericName = "Launch a Private Ungoogled Chromium Instance";
          icon = "chromium";
          exec = "${ungoogled-chromium}/bin/chromium --incognito";
          categories = [ "Network" ];
        })
      ];

    programs.chromium = {
      enable = true;
      package =
        let
          ungoogledFlags = toString [
            "--force-dark-mode"
            "--disable-search-engine-collection"
            "--extension-mime-request-handling=always-prompt-for-install"
            "--fingerprinting-canvas-image-data-noise"
            "--fingerprinting-canvas-measuretext-noise"
            "--fingerprinting-client-rects-noise"
            "--popups-to-tabs"
            "--show-avatar-button=incognito-and-guest"

            # Performance
            "--enable-gpu-rasterization"
            "--enable-oop-rasterization"
            "--enable-zero-copy"
            "--ignore-gpu-blocklist"

            # Experimental features
            "--enable-features=${
            concatStringsSep "," [
              "BackForwardCache:enable_same_site/true"
              "CopyLinkToText"
              "OverlayScrollbar"
              "TabHoverCardImages"
              "VaapiVideoDecoder"
            ]
          }"
          ];
        in
        pkgs.ungoogled-chromium.override {
          commandLineArgs = [ ungoogledFlags ];
        };
      extensions = [
        { id = "jhnleheckmknfcgijgkadoemagpecfol"; } # Auto-Tab-Discard
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        { id = "dlnejlppicbjfcfcedcflplfjajinajd"; } # Bonjourr (New-Tab Page)
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark-Reader
        { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # Decentraleyes
        { id = "bkdgflcldnnnapblkhphbgpggdiikppg"; } # DuckDuckGo
        { id = "gbefmodhlophhakmoecijeppjblibmie"; } # Linguist
        { id = "hlepfoohegkhhmjieoechaddaejaokhf"; } # Refined GitHub
        { id = "iaiomicjabeggjcfkbimgmglanimpnae"; } # Tab-Session-Manager
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # Ublock-Origin
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
        { id = "jinjaccalgkegednnccohejagnlnfdag"; } # Violentmonkey
        {
          id = "dcpihecpambacapedldabdbpakmachpb";
          updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml";
        }
        # (mkIf config.modules.desktop.gnome.enable [
        # {
        # id = "gphhapmejobijbbhgpjhcjognlahblep";
        # } # Gnome-Shell-Integration
        # ])
      ];
    };
  };
}
