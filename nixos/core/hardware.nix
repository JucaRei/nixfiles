{ config, pkgs, lib, isWorkstation, hostname, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption types optionalString optional optionals mapAttrsToList concatStringsSep;
  cfg = config.sys.hardware;
in
{
  options.sys.hardware = {
    enable = mkEnableOption "hardware defaults" // {
      default = true;
    };

    systemdBoot = mkEnableOption "common boot config";
    hardenKernel = mkEnableOption "kernel hardening options" // {
      default = false; # isWorkstation;
    };
    improveTCP = mkEnableOption "tcp extra config." // { default = true; };
    enableKvm = mkEnableOption "kernel hardening options";

    cpuVendor = mkOption {
      type = types.enum [
        "intel"
        "amd"
        "other"
      ];
      default = "intel";
      description = ''
        Vendor for the CPU, meant mostly for x86/x86_64 systems.
      '';
    };

  };

  config = mkIf cfg.enable {
    boot = {
      extraModprobeConfig = mkIf cfg.enableKvm ''
        options ${optionalString (cfg.cpuVendor != "other") "kvm_${cfg.cpuVendor}"} nested=1
      '';

      kernelModules = mkIf cfg.improveTCP [ "tcp_bbr" ];
      kernel = {
        sysctl =
          let
            # harden = concatStringsSep "\n"
            #   mapAttrsToList
            #   (
            #     key: value:
            #       "${key} = ${value}"
            #   )
            #   cfg.hardenKernel;

            # tcp = concatStringsSep "\n"
            #   mapAttrsToList
            #   (
            #     key: value:
            #       "${key} = ${value}"
            #   )
            #   cfg.hardenKernel;
            harden = {
              # Prevent unintentional fifo writes
              "fs.protected_fifos" = 2;

              # Prevent unintended writes to already-created files
              "fs.protected_regular" = 2;

              # Disable SUID binary dump
              "fs.suid_dumpable" = 0;

              # Require user to have CAP_SYSLOG to use dmesg
              "kernel.dmesg_restrict" = 1;

              # Prevent printing kernel pointers
              "kernel.kptr_restrict" = 2;

              # Disallow profiling at all levels without CAP_SYS_ADMIN
              "kernel.perf_event_paranoid" = 3;

              # Disable "Sysrq" key
              "kernel.sysrq" = 0;

              # Require CAP_BPF to use bpf
              "kernel.unprvileged_bpf_disabled" = 1;

              # Filter ARP packets to be responded on per-interface. Not sure why this isn't the default
              "net.ipv4.conf.all.arp_filter" = 1;

              # Filter Reverse Path
              "net.ipv4.conf.all.rp_filter" = 1;

              # Log impossible addr packets
              "net.ipv4.conf.all.log_martians" = 1;
              "net.ipv4.conf.default.log_martians" = 1;
            };

            tcp = {
              # Disable NMI watchdog
              "kernel.nmi_watchdog" = 0;

              ## TCP hardening
              # Prevent bogus ICMP errors from filling up logs.
              "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

              # Reverse path filtering causes the kernel to do source validation of
              # packets received from all interfaces. This can mitigate IP spoofing.
              "net.ipv4.conf.default.rp_filter" = 1;
              "net.ipv4.conf.all.rp_filter" = 1;

              # Do not accept IP source route packets (we're not a router)
              # "net.ipv4.conf.all.accept_source_route" = 0;
              # "net.ipv6.conf.all.accept_source_route" = 0;

              # Don't send ICMP redirects (again, we're on a router)
              # "net.ipv4.conf.all.send_redirects" = 0;
              # "net.ipv4.conf.default.send_redirects" = 0;

              # Refuse ICMP redirects (MITM mitigations)
              # "net.ipv4.conf.all.accept_redirects" = 0;
              # "net.ipv4.conf.default.accept_redirects" = 0;
              # "net.ipv4.conf.all.secure_redirects" = 0;
              # "net.ipv4.conf.default.secure_redirects" = 0;
              # "net.ipv6.conf.all.accept_redirects" = 0;
              # "net.ipv6.conf.default.accept_redirects" = 0;

              # Protects against SYN flood attacks
              "net.ipv4.tcp_syncookies" = 1;

              # Incomplete protection again TIME-WAIT assassination
              "net.ipv4.tcp_rfc1337" = 1;

              # TCP optimization
              # TCP Fast Open is a TCP extension that reduces network latency by packing
              # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
              # both incoming and outgoing connections:
              "net.ipv4.tcp_fastopen" = 3;

              # Bufferbloat mitigations + slight improvement in throughput & latency
              "net.ipv4.tcp_congestion_control" = "bbr";
              # "net.core.default_qdisc" = "cake";
            };

          in
          # mkIf cfg.hardenKernel lib.attrsets.mapAttrsToList (key: value: "${key} = ${value}" harden) harden
            # ++ optional cfg.improveTCP lib.attrsets.mapAttrsToList (key: value: "${key} = ${value}" tcp) tcp;
            # mkIf cfg.hardenKernel [ builtins.map (key: value: "${key} = ${value}" harden) harden ]
            # ++ mkIf cfg.improveTCP [ builtins.map (key: value: "${key} = ${value}" tcp) tcp ];
            #   ++ (optionals cfg.improveTCP { })

          mkIf cfg.hardenKernel
            {
              inherit harden;
            } ++ mkIf (cfg.improveTCP mapAttrsToList (key: value: "${key}=${value}") [ tcp ]);
      };

      kernelParams = (optional (cfg.cpuVendor == "intel") "intel_iommu=on");
    };

    environment.systemPackages = optionals isWorkstation (
      with pkgs;
      [
        usbutils
        pciutils
      ]
    );

    hardware = {
      bluetooth = mkIf isWorkstation {
        enable = true;
        package = pkgs.bluez;
        # package = pkgs.unstable.bluez-experimental;
        powerOnBoot = false;
        settings = {
          General.Name = config.networking.hostName;
          # Enable = "Source,Sink,Media,Socket";
          # JustWorksRepairing = "always";
          # MultiProfile = "multiple";
          # # make Xbox Series X controller work
          # # Class = "0x000100";
          # ControllerMode = "bredr";
          # FastConnectable = true;
          # Privacy = "device";
          # Experimental = true;
        };
      };

      cpu.intel.updateMicrocode = cfg.cpuVendor == "intel";
      enableRedistributableFirmware = true;
    };

    services.fwupd.enable = isWorkstation;
    zramSwap.enable = true;
  };
}