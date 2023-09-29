{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ unstable.quickemu ];
}
