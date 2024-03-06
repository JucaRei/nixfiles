{
  system.autoUpgrade = {
    enable = true;
    flake = "git+ssh://git@github.com/JucaRei/nixfiles?ref=main";
    #flake = "git+file:///etc/nixos/";
    flags = [
      "--recreate-lock-file"
      "--no-write-lock-file"
    ]; # updates all inputs but don't write anything to FS
    dates = "04:00:00";
    allowReboot = true;
    rebootWindow = {
      lower = "04:00";
      upper = "06:00";
    };
  };
}
