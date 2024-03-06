{
  config,
  pkgs,
  ...
}: {
  services.tlp = {
    settings = {
      # https://wiki.archlinux.org/title/Wake-on-LAN#Enable_WoL_in_TLP
      WOL_DISABLE = "N";
    };
  };

  networking.interfaces."enp7s0f1".wakeOnLan.enable = true;

  environment.systemPackages = with pkgs; [
    # ethtool can be used to manually enable wakeOnLan, eg:
    #
    #    sudo ethtool -s enp7s0f1 wol g
    #
    # on verify its status:
    #
    #    sudo ethtool enp7s0f1 | grep Wake-on
    ethtool
  ];
}
