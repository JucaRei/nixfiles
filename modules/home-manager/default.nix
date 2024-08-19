{ pkgs, lib, inputs, config, stateVersion, username, isLima, isWorkstation, ... }:
let
  # inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (pkgs) stdenv;
  # archtype = if (isDarwin) then ./darwin else ./linux;
  pathToArch =
    if (stdenv.isLinux == true) then
      ./. + "./linux"
    else
      ./. + "./darwin";
  path = import pathToArch;
in
{
  ### Default for any system
  imports = [
    ../../home
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Modules exported from other flakes:
    inputs.catppuccin.homeManagerModules.catppuccin
    # inputs.determinate.homeModules.default
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.hmModules.nix-index
  ] ++ path;


  catppuccin = {
    accent = "blue";
    flavor = "mocha";
  };

  home = {
    inherit stateVersion username;
    homeDirectory =
      if stdenv.isDarwin then "/Users/${username}"
      else if isLima then "/home/${username}.linux"
      else "/home/${username}";

    file = {
      "${config.xdg.configHome}/fastfetch/config.jsonc".text = builtins.readFile ../../resources/configs/fastfetch.jsonc;
      "${config.xdg.configHome}/gh-dash/config.yml".text = builtins.readFile ../../resources/configs/gh-dash-catppuccin-mocha-blue.yml;
      "${config.xdg.configHome}/yazi/keymap.toml".text = builtins.readFile ../../resources/configs/yazi-keymap.toml;
      "${config.xdg.configHome}/fish/functions/help.fish".text = builtins.readFile ../../resources/configs/help.fish;
      "${config.xdg.configHome}/fish/functions/h.fish".text = builtins.readFile ../../resources/configs/h.fish;
      ".hidden".text = ''snap'';
    };

    packages = with pkgs; [
      duf # Modern Unix `df`
      fd # Modern Unix `find`
      speedtest-go # Terminal speedtest.net
      tldr # Modern Unix `man`
    ] ++ lib.optionals isLinux [
      iw # Terminal WiFi info
      pciutils # Terminal PCI info
      usbutils # Terminal USB info
    ]
    ++ lib.optional isDarwin [
      m-cli # Terminal Swiss Army Knife for macOS
      nh
      lima-bin # Terminal VM manager
      coreutils
    ];

    sessionVariables = lib.mkDefault {
      EDITOR = "micro";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      MANROFFOPT = "-c";
      MICRO_TRUECOLOR = "1";
      PAGER = "bat";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      FLAKE = "/home/${username}/.dotfiles/nixfiles";
    };

    shellAliases = {
      mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
      mkdir = "mkdir -pv";
      ip = "${pkgs.iproute2}/bin/ip --color --brief";
      less = "${pkgs.bat}/bin/bat --paging=always";
      more = "${pkgs.bat}/bin/bat --paging=always";
      du = "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
      audio = "${pkgs.inxi}/bin/inxi -A";
      battery = "${pkgs.inxi}/bin/inxi -B -xxx";
      bluetooth = "${pkgs.inxi}/bin/inxi -E";
      graphics = "${pkgs.inxi}/bin/inxi -G";
      system = "${pkgs.inxi}/bin/inxi -Fazy";
      usb = "${pkgs.inxi}/bin/inxi -J";
      wifi = "${pkgs.inxi}/bin/inxi -n";
      dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
      store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
    };
  };

  fonts.fontconfig.enable = true;

  systemd.user = {
    # Nicely reload system units when changing configs
    startServices = lib.mkIf stdenv.isLinux "sd-switch";

    services.nix-index-database-sync = {
      Unit.Description = "fetch mic92/nix-index-database";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "fetch-nix-index-database";
          runtimeInputs = with pkgs; [ wget coreutils ];
          text = ''
            mkdir -p ~/.cache/nix-index
            cd ~/.cache/nix-index
            name="index-${pkgs.stdenv.system}"
            wget -N "https://github.com/Mic92/nix-index-database/releases/latest/download/$name"
            ln -sf "$name" "files"
          '';
        });
        Restart = "on-failure";
        RestartSec = "5m";
      };
    };

    timers.nix-index-database-sync = {
      Unit.Description = "Automatic github:mic92/nix-index-database fetching";
      Timer = {
        OnBootSec = "10m";
        OnUnitActiveSec = "24h";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  xdg = {
    enable = stdenv.isLinux;
    userDirs = {
      # Do not create XDG directories for LIMA; it is confusing
      enable = stdenv.isLinux && !isLima;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
  };

  programs = {
    home-manager = {
      enable = true;
      path = "$HOME/.config/home-manager";
    };
  };
}
