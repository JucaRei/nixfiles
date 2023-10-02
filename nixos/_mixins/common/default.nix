{ hostid, hostname, lib, pkgs, ... }: {
  imports = [
    ./aliases.nix
    ./console.nix
    ./locale.nix
    ./fonts.nix
    # ./nano.nix
    # ../config/qt/qt-style.nix
    ../services/security/sudo.nix
    ../services/security/common.nix
    ../services/security/detect-reboot-needed.nix
    # ../services/power/powertop.nix
    ../hardware/other/fwupd.nix
    ../hardware/other/usb.nix
    ../services/tools/fhs.nix
    # ../services/openssh.nix
    # ../services/tailscale.nix
    # ../services/zerotier.nix
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
      "vhost_vsock"
      "tcp_bbr"
    ];
    kernelParams = [
      # The 'splash' arg is included by the plymouth option
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    kernel = {
      sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;

        ### Improve networking
        # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
        "kernel.sysrq" = 1;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";
        #"net.core.default_qdisc" = "fq";

        # Bypass hotspot restrictions for certain ISPs
        "net.ipv4.ip_default_ttl" = 65;

        "vm.swappiness" = 30;
        # TODO: the higher default of 10% of RAM would be better here,
        # but it makes removable storage dangerous as it's a system wide setting
        # and there's no way to make the limit smaller for removable storeage
        # I also haven't found an easy way to make removeable storage mount with sync option
        "vm.dirty_bytes" = 1024 * 1024 * 512;
        "vm.dirty_background_bytes" = 1024 * 1024 * 32;
      };
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
    ];
    variables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  # programs = {
  #   fish.enable = true;
  # };

  # security.rtkit.enable = true;
}
