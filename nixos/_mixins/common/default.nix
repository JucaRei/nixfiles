{ hostid, hostname, lib, pkgs, ... }: {
  imports = [
    ./aliases.nix
    ./aspell.nix
    ./console.nix
    ./locale.nix
    ./fonts.nix
    # ./nano.nix
    # ../config/qt/qt-style.nix
    # ../console/fish.nix
    # ../services/security/sudo.nix
    # ../services/security/doas.nix
    ../services/security/common.nix
    ../services/network/avahi.nix
    # ../services/security/detect-reboot-needed.nix
    # ../services/power/powertop.nix
    ../hardware/other/fwupd.nix
    ../hardware/other/usb.nix
    # ../virtualization/nix-ld.nix
    # ../services/tools/fhs.nix
    # ../services/openssh.nix
    # ../services/tailscale.nix
    # ../services/zerotier.nix
    ../config/scripts/nixos-change-summary.nix
  ];

  # don't install documentation i don't use
  documentation = {
    enable = true; # documentation of packages
    nixos.enable = false; # nixos documentation
    man.enable = true; # manual pages and the man command
    info.enable = false; # info pages and the info command
    doc.enable = false; # documentation distributed in packages' /share/doc
  };

  ############################
  ### Default Boot Options ###
  ############################
  boot = {
    initrd = {
      verbose = lib.mkDefault false;
    };
    consoleLogLevel = 0;
    kernelModules = [
      "kvm-intel"
      "vhost_vsock"
      "tcp_bbr"
    ];
    kernelParams = [
      # The 'splash' arg is included by the plymouth option
      "boot.shell_on_fail"
      # "loglevel=3"
      # "rd.systemd.show_status=false"
      # "rd.udev.log_level=3"
      # "udev.log_priority=3"
      "vt.global_cursor_default=0"
      "mitigations=off"
    ];
    kernel = {
      sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;

        # "vm.nr_hugepages" = lib.mkDefault "0"; # disabled is better for DBs

        ### Improve networking
        # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
        "kernel.sysrq" = 1; # magic keyboard shortcuts
        # TCP Fast Open is a TCP extension that reduces network latency by packing
        # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
        # both incoming and outgoing connections:
        "net.ipv4.tcp_fastopen" = 3;
        # Bufferbload mitigations + slight improvement in throughput & latency
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";
        #"net.core.default_qdisc" = "fq";

        # Bypass hotspot restrictions for certain ISPs
        "net.ipv4.ip_default_ttl" = 65;

        "vm.swappiness" = 30; # default 60, between 0 to 100. 10 means try to not swap
        "vm.vfs_cache_pressure" = 200; # default 100, recommended between 50 to 500. 500 means less file cache for less swapping
        # TODO: the higher default of 10% of RAM would be better here,
        # but it makes removable storage dangerous as it's a system wide setting
        # and there's no way to make the limit smaller for removable storeage
        # I also haven't found an easy way to make removeable storage mount with sync option
        "vm.dirty_bytes" = 1024 * 1024 * 512;
        "vm.dirty_background_bytes" = 1024 * 1024 * 32;
        "vm.dirty_background_ratio" = 10; # default 10, start writting dirty pages at this ratio
        "vm.dirty_ratio" = 40; # default 20, maximum ratio, block process when reached
      };
    };
    supportedFilesystems = [
      "ext4"
      "btrfs"
      "exfat"
      "ntfs"
    ];

    # Appimage Registration
    binfmt.registrations.appimage = {
      # make appImage work seamlessly
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      # mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
      magicOrExtension = "\\x7fELF....AI\\x02";
      # magicOrExtension = ''\x7fELF....AI\x02'';
    };

  };

  ##############################
  ### Packages for all hosts ###
  ##############################

  environment = {
    # Eject nano and perl from the system
    defaultPackages = with pkgs; lib.mkForce [
      gitMinimal
      home-manager
      micro
      rsync
    ];
    systemPackages = with pkgs; [
      agenix
      pciutils
      psmisc
      unzip
      usbutils
      binutils
      curl
      duf
      htop
      lshw
      inspect
      #unstable.nix-index
      #unstable.nix-prefetch-git
      # cifs-utils
    ] ++ (with pkgs.unstable; [
      # Minimal for nix code
      nil
      nixpkgs-fmt
      nixpkgs-lint
    ]);
    variables = {
      # use Wayland where possible (electron)
      NIXOS_OZONE_WL = "1";
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
    etc = {
      # Allow for dynamic hosts file override (by root)
      hosts.mode = "0644";
    };
  };

  programs = {
    #   fish.enable = true;
    fuse = {
      userAllowOther = true;
    };

    mtr = {
      enable = true;
    };

    # Minimal
    nix-ld = {
      enable = true;
      libraries = with pkgs; [

        curl
        glib
        glibc
        icu
        libsecret
        libunwind
        libuuid

        # openssl
        stdenv.cc.cc
        util-linux
        zlib

        # graphical
        freetype
        libglvnd
        libnotify
        SDL2
        vulkan-loader
        gdk-pixbuf
        xorg.libX11

      ];
    };

    # type "fuck" to fix the last command that made you go "fuck"
    thefuck.enable = true;
  };

  # security.rtkit.enable = true;

  services = {
    # Temperature management daemon
    thermald = {
      enable = true;
    };

    # Auto Nice Daemon
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
    };

    # Keeps the system timezone up-to-date based on the current location
    automatic-timezoned = {
      enable = true;
    };

    # profile-sync-daemon
    psd = {
      enable = true;
      resyncTimer = "10m";
    };

    udev = {
      enable = true;

      # enable high precision timers if they exist
      # (https://gentoostudio.org/?page_id=420)
      extraRules = ''
        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
      '';
    };

    # https://unix.stackexchange.com/a/175035
    # acpid.acEventCommands = ''
    #   echo -1 > /sys/module/usbcore/parameters/autosuspend
    # '';

    # envfs.enable = true; # populate /usr/bin for non-nix binaries
  };

  security = {
    # Enables simultaneous use of processor threads.
    allowSimultaneousMultithreading = true;

    pam = {
      mount = {
        enable = true;
      };
    };
  };

  systemd = lib.mkDefault {
    # systemd = lib.mkOverride 20 {
    services.disable-wifi-powersave = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iw ];
      script = ''
        iw dev wlan0 set power_save off
      '';
    };

  };
  # enableUnifiedCgroupHierarchy = lib.mkForce true; #cgroupsv2

  # Controlling external screens
  services.ddccontrol.enable = true;
  hardware = {
    i2c.enable = true;
  };

  # enable location service
  location.provider = "geoclue2";
}
