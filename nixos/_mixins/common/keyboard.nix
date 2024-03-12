{ hostname
, lib
, ...
}: {
  # services.xserver = if (hostname == "nitro") then {
  services.xserver = {
    #   xkb = {
    #     layout = "br";
    #     variant = "abnt2";
    #     model = "pc105";
    #     options = "grp:alt_shift_toggle,caps:none";
    #     # options = "eurosign:e";
    #   };
    # } else {
    #   xkb = {
    #     layout = "us";
    #     variant = "mac";
    #     model = "pc105";
    #     options = "grp:alt_shift_toggle,caps:none";
    #   };
    libinput = {
      enable = true;
      touchpad = {
        # horizontalScrolling = true;
        # tappingDragLock = false;
        tapping = true;
        naturalScrolling = true;
        scrollMethod = "twofinger";
        disableWhileTyping = true;
        sendEventsMode = "disabled-on-external-mouse";
        # clickMethod = "clickfinger";
      };
      mouse = {
        naturalScrolling = false;
        disableWhileTyping = true;
        accelProfile = "flat";
      };
    };
    exportConfiguration = true;
  };

  console = {
    keyMap =
      if hostname == "nitro"
      then "br-abnt2"
      else "us";
    font = lib.mkDefault "Lat2-Terminus16";
  };
}
