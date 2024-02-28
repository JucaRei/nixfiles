{pkgs, ...}: {
  imports = [
    ./config/scripts/home-manager_change_summary.nix
    ./console/aliases.nix
    ./console/bat
    # ./console/bash.nix
    ./console/fish
    # ./console/bottom.nix
    ./console/dircolors.nix
    ./console/direnv.nix
    # ./console/eza.nix
    ./console/eza.nix
    ./console/htop
    ./console/git.nix
    ./console/micro.nix
    ./console/neofetch.nix
    # ./console/skim.nix
    ./console/starship.nix
  ];

  home = {
    # For all machines
    packages = with pkgs; [
      duf # Modern Unix `df`
      wget2 # Terminal downloader
      moar # Modern Unix `less`
      nix-cleanup
      nix-whereis
      cachix
    ];

    sessionVariables = let
      editor = "micro"; # change for whatever you want
    in {
      EDITOR = "${editor}";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      PAGER = "moar";
      SYSTEMD_EDITOR = "${editor}";
      VISUAL = "${editor}";
    };
  };

  programs = {
    command-not-found.enable = false;
    gpg.enable = true;
    info.enable = true;
    jq = {
      enable = true;
      package = pkgs.jiq;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "curses";
    };
    kbfs = {
      enable = true;
      mountPoint = "Keybase";
    };
    keybase.enable = true;
  };
}
