{ pkgs, lib, username, ... }:
with lib.hm.gvariant;
let
  kodiAndPlugins = pkgs.kodi-gbm.withPackages (kodiPkgs: with kodiPkgs; [
    trakt
    youtube
    libretro
    inputstream-ffmpegdirect
    inputstream-adaptive
    pvr-iptvsimple
    netflix
    jellycon
  ]);
in
{
  # home.packages = with pkgs;
  #   [ kodi ] ++ (with kodiPackages; [ trakt youtube jellyfin ]);

  # programs = {
  #     jellyfin = {
  #         enable = true;
  #         user = username;
  #     };
  #     jellyseerr.enable = true;
  #     jellyfin.openFirewall = true;
  # };

  # services.xserver.desktopManager.session = [{
  #   name = "kodi";
  #   start = ''
  #     ${pkgs.kodi}/bin/kodi --lircdev /var/run/lirc/lircd --standalone &
  #     waitPID=$!
  #   '';
  # }];

  # Kodi GBM service
  # systemd.user.enable = true;
  systemd.user.services.kodi = {
    Unit.Description = "Kodi media center";
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${kodiAndPlugins}/bin/kodi-standalone";
      Restart = "always"; # on-failure
      TimeoutStopSec = "15s";
      TimeoutStopFailureMode = "kill";
    };
  };

  programs.kodi = {
    enable = true;
    package = kodiAndPlugins;
    # addonSettings = {};
    settings = {
      services = {
        devicename = "viewscreen";
        esallinterfaces = "true";
        webserver = "true";
        webserverport = "8080";
        webserverauthentication = "false";
        zeroconf = "true";
      };
    };
  };

  # users.extraUsers.kodi ={
  #   isNormalUser = true;
  #   extraGroups = [ "audio" "video" "input" ];
  #   linger = true;
  # };

  # networking.firewall = {
  #   allowedTCPPorts = [ 8080 ];
  #   allowedUDPPorts = [ 8080 ];
  # };
}

# language:nix /bash-completion.*?\/git[^-a-zA-Z\/]/ -path:**/git-and-tools/** -path:**/version-management/**
