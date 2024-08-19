{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      nix
      nil
      nixpkgs-fmt
      nixd
    ];
  };
}
