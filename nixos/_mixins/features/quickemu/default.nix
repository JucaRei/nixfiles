{ inputs
, isWorkstation
, lib
, pkgs
, platform
, username
, ...
}:
let
  installFor = [ "juca" ];
in
lib.mkIf (lib.elem "${username}" installFor && isWorkstation) {
  environment = {
    systemPackages = with pkgs; [
      inputs.quickemu.packages.${platform}.default
      inputs.quickgui.packages.${platform}.default
    ];
  };
  virtualisation = {
    spiceUSBRedirection.enable = true;
  };
}
