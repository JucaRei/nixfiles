{pkgs, ...}: {
  home.packages = with pkgs; [
    usbimager
  ];

  xdg = {
    desktopEntries = {
      # The usbimager icon pasth is hardcoded, so override the desktop file
      usbimager = {
        name = "USBImager";
        exec = "${pkgs.usbimager}/bin/usbimager";
        terminal = false;
        icon = "usbimager";
        type = "Application";
        categories = ["System" "Application"];
      };
    };
  };
}
