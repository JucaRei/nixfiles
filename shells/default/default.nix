{ pkgs
, inputs
, ...
}:
pkgs.mkShell {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";

  packages = with pkgs; [
    nh
    inputs.nixos-anywhere.packages.${pkgs.system}.nixos-anywhere
    statix
    deadnix
    # alejandra
    # dropbear # ssh
    nixpkgs-fmt
    home-manager
    git
    sops
    ssh-to-age
    gnupg
    age
  ];

  shellHook = ''
    # alias ssh="dbclient"
    echo "
      . _____   _           _
      |  ____| | |         | |
      | |__    | |   __ _  | | __   ___   ___
      |  __|   | |  / _\` | | |/ /  / _ \ / __|
      | |      | | | (_| | |   <  |  __/ \\__ \\
      |_|      |_|  \__,_| |_|\_\  \___| |___/
    "
  '';
}
