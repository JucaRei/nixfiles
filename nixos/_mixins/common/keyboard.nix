{ hostname, lib, ... }: {
  services.xserver = if (hostname == "nitro") then {
    xkb = {
      layout = "br";
      variant = "abnt2";
      model = "pc105";
      options = "grp:alt_shift_toggle,caps:none";
    };
  } else {
    xkb = {
      layout = "us";
      variant = "mac";
      model = "pc105";
      options = "grp:alt_shift_toggle,caps:none";
    };
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
}
