{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    brave
  ];
}
