{ pkgs, ... }: {
  imports = [
    ./config/scripts/home-manager_change_summary.nix
    ./console/aliases.nix
    ./console/bat
    ./console/bash.nix
    # ./console/bottom.nix
    ./console/dircolors.nix
    ./console/direnv.nix
    # ./console/eza.nix
    ./console/eza1.nix
    # ./console/exa.nix
    ./console/htop.nix
    ./console/git.nix
    ./console/micro.nix
    ./console/neofetch.nix
    # ./console/skim.nix
    ./console/starship.nix
    ./console/yt-dlp.nix
    ./fonts
  ];

  home = {
    # For all machines
    packages = with pkgs; [
      duf # Modern Unix `df`
      wget2 # Terminal downloader
      ncdu_1
      moar # Modern Unix `less`
      coreutils
      pandoc
      nix-cleanup
      nix-whereis
      cachix
    ];

    sessionVariables = {
      EDITOR = "micro";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      PAGER = "moar";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
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
