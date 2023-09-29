{ pkgs, ... }: {
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
    package = pkgs.unstable.atuin;
    settings = {
      auto_sync = true;
      dialect = "us";
      show_preview = true;
      style = "compact";
      sync_frequency = "1h";
      sync_address = "https://api.atuin.sh";
      update_check = false;
    };
  };
}
