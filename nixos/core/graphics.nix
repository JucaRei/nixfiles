{ inputs, config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkPackageOption
    mkOption
    optionals
    ;
  cfg = config.sys.graphics;
in
{
  options.sys.graphics = {
    enable = mkEnableOption "nvidia";

    manufacturer = mkOption {
      type = lib.types.enum [ "unknown" "rpi" "amd" "intel" "nvidia" ];
      default = "unknown";
      description = "The manufacturer of your GPU";
    };
    package = mkPackageOption config.boot.kernelPackages.nvidiaPackages "stable" { };
    firefox-fix = mkEnableOption "nvidia firefox fix" // {
      default = true;
    };
    nvidia-patch = mkEnableOption "nvidia-patch";
    sway-fix = mkEnableOption "nvidia sway fix" // {
      default = true;
    };
  };

  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];

  config = mkIf cfg.enable (mkMerge [
    {
      boot = {
        initrd.kernelModules = optionals (cfg.graphics.manufacturer == "nvidia") [ "nvidia" "nvidia_modeset" "nvidia_drm" ];
        kernelParams = optionals (cfg.graphics.manufacturer == "nvidia") [
          "nvidia.NVreg_EnableResizableBar=1"
          "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
          "nvidia-drm.fbdev=1"
        ];
        loader.grub.gfxmodeEfi = mkDefault "1920x1080";
        hardware.nvidia.modesetting.enable = optionals (cfg.graphics.manufacturer == "nvidia") true;
        hardware.nvidia.package = cfg.package;
        # hardware.nvidia.prime = {
        #   intelBusId = "PCI:0:2:0";
        #   nvidiaBusId = "PCI:1:0:0";
        #   offload.enable = true;
        #   offload.enableOffloadCmd = true;
        # };
        services.xserver.videoDrivers = [ "nvidia" ];

        # Sway complains even nvidia GPU is only used for offload
        programs.sway.extraOptions = [ "--unsupported-gpu" ];
      };
    }

    ({
      hardware = {
        graphics.enable = true;
        nvidia = mkIf (cfg.graphics.manufacturer == "nvidia") {
          package = config.boot.kernelPackages.nvidiaPackages.beta;
          open = true;
          nvidiaSettings = true;
          nvidiaPersistenced = true;
          modesetting.enable = true;
          forceFullCompositionPipeline = true;
          powerManagement = {
            enable = true;
          };
        };
      };
    })

    ({
      services.xserver.videoDrivers =
        if (cfg.graphics.manufacturer == "nvidia") then
          [ "nvidia" ]
        else if (cfg.graphics.manufacturer == "amd") then
          [ "amdgpu" ]
        else
          [ "modesetting" "fbdev" ];
    })

    (mkIf cfg.firefox-fix {
      # https://github.com/elFarto/nvidia-vaapi-driver
      hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];
      hm.my.firefox.env.GDK_BACKEND = null;
      hm.my.firefox.env.MOZ_DISABLE_RDD_SANDBOX = "1";
      hm.programs.firefox.profiles.default.settings = {
        "widget.dmabuf.force-enabled" = true;
      };
    })

    (mkIf cfg.nvidia-patch {
      hardware.nvidia.package = cfg.package.overrideAttrs (old: {
        preFixup =
          (old.preFixup or "")
          + ''
            patch_nvidia() {
              local patch_file patch_sed so_file
              patch_file=$1
              so_file=$2
              patch_sed=$(grep -m 1 -F '"${old.version}"' "${inputs.nvidia-patch}/$patch_file" | cut -d "'" -f 2)
              echo "patching $so_file with $patch_sed"
              sed -i "$patch_sed" "$out/lib/$so_file"
            }
            patch_nvidia patch.sh libnvidia-encode.so
            patch_nvidia patch-fbc.sh libnvidia-fbc.so
          '';
      });
    })

    (mkIf cfg.sway-fix {
      # sway/wlroots vulkan need vulkan-validation-layers for now, may remove on later version.
      # https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/3850
      environment.systemPackages = [ pkgs.vulkan-validation-layers ];
      # export WLR_RENDERER=vulkan
      programs.sway.extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
      '';
    })
  ]);
}

# https://forums.developer.nvidia.com/t/550-54-14-cannot-create-sg-table-for-nvkmskapimemory-spammed-when-launching-chrome-on-wayland/284775/26

# TODO: confirm this works - and remove pervious line if not needed, or revert to it if this doesn't work.
# https://discourse.nixos.org/t/nvidia-drivers-not-loading/40913/11?u=brnix
# Don’t add nvidia-uvm to kernelModules, because we want nvidia-uvm be loaded only after udev rules for nvidia kernel module are applied.

# initrd.kernelModules = [ "nvidia" "i915" "nvidia_modeset" "nvidia_drm" ];

# # extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
# kernelParams = [ "nvidia-drm.fbdev=1" ];
