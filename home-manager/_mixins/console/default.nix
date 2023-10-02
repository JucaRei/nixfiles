{ pkgs, ... }: {
  imports = [
    ./aliases.nix
    # ./atuin.nix
    ./bat.nix
    ./bash.nix
    # ./btop.nix
    ./bottom.nix
    ./dircolors.nix
    ./direnv.nix
    ./exa.nix
    # ./eza.nix
    ./htop.nix
    # ./fish.nix
    ./git.nix
    # ./glow.nix
    ./micro.nix
    ./neofetch.nix
    ./skim.nix
    ./starship.nix
    # ./xdg.nix
    # ./zoxide.nix
  ];

  home = {
    packages = with pkgs; [
      duf # Modern Unix `df`
      wget2 # Terminal downloader
      ncdu_1
      moar # Modern Unix `less`
      neovim
    ] ++ pkgs.unstable.nvchad;

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
    home-manager.enable = true;
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
