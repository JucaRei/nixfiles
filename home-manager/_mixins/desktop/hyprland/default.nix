{ pkgs, lib, config, inputs, hostname, ... }: {
  home = {
    packages = with pkgs; [
      kitty # terminal
      mako # notification daemon
      libsForQt5.polkit-kde-agent # polkit agent
    ];
  };
  wayland =
    let
      nvidiaEnabled = (lib.elem "nvidia" config.services.xserver.videoDrivers);
    in
    {
      windowManager = {
        hyprland = {
          enable = true;
          # Check if it has nvidia and nvidia Driver installed
          enableNvidiaPatches = if nvidiaEnabled != true then false else true;
          package = inputs.hyprland.packages.${pkgs.system}.hyprland.override {
            enableXWayland = true; # whether to enable XWayland
            legacyRenderer = if hostname == "nitro" then false else true; # false; # whether to use the legacy renderer (for old GPUs)
            withSystemd = if hostname == "nitro" then true else false; # whether to build with systemd support
          };
          # extraConfig = '''';
          # finalPackage = '''';
          # plugins = [];
          # settings = {};
          systemd = {
            enable = true;
            # extraCommands = "";
            # variable = [];
          };
          xwayland.enable = true;
        };
      };
    };

$mainMod = if hostname == "nitro" || "vm" then ALT else SUPER

}
