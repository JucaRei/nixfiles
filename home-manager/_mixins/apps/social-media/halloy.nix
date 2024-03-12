{pkgs, config,...}: {
  home = {
    packages = with pkgs; [
      halloy
    ];

    file = {
      "${config.xdg.configHome}/halloy/themes/harmony-dark.yaml".text = builtins.readFile ../../config/halloy/harmony-dark.yaml;
    };
  };
}
