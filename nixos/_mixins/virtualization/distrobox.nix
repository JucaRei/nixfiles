{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      distrobox # Terminal container manager
      xorg.xhost
    ];
    # shellInit = ''
    #   [ -n "$DISPLAY" ] && xhost +si:localuser:$USER || true
    # '';
  };
}
