{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.services.plymouth;
in
{
  options.services.plymouth = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable plymouth animation for boot start.
      '';
    };
  };
  config = mkIf cfg.enable {
    boot =
      {
        consoleLogLevel = 0;
        initrd = {
          systemd.enable = true;
          verbose = false;
        };
        kernelParams = mkForce [
          "quiet"
          "splash"
          "vga=current"
          "systemd.show_status=auto"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"

          # performance improvement for direct-mapped memory-side-cache utilization
          # reduces the predictability of page allocations
          "page_alloc.shuffle=1"

          # ignore access time (atime) updates on files
          # except when they coincide with updates to the ctime or mtime
          "rootflags=noatime"

          # prevent the kernel from blanking plymouth out of the fb
          "fbcon=nodefer"
        ];
        kernel = {
          sysctl = {
            "kernel.printk" = "3 3 3 3"; # "4 4 1 7";

            # Hide kptrs even for processes with CAP_SYSLOG
            # also prevents printing kernel pointers
            "kernel.kptr_restrict" = 2;

            # Disable ftrace debugging
            "kernel.ftrace_enabled" = false;

            # Disable NMI watchdog
            "kernel.nmi_watchdog" = 0;
          };
        };
        plymouth = rec {
          enable = true;
          # black_hud circle_hud cross_hud square_hud
          # circuit connect cuts_alt seal_2 seal_3

          # logo = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";
          theme = "deus_ex";
          themePackages = with pkgs; [
            (
              # pkgs.catppuccin-plymouth
              adi1090x-plymouth-themes.override {
                selected_themes = [ theme ];
              }
            )
          ];
        };
      };
    systemd.watchdog.rebootTime = "0";
  };
}
