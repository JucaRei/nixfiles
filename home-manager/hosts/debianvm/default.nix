{ pkgs, lib, ... }:
{
  imports = [
    ../../_mixins/non-nixos
  ];
  config = {
    custom = {
      nonNixOs.enable = true;
    };
    home.packages =
      [
        # (nixGLVulkanMesaWrap pkgs.st)
        # (nixGLVulkanMesaWrap pkgs.firefox)
        # (nixGLVulkanMesaWrap pkgs.thorium)
      ]
      ++ (with pkgs; [ inxi ]);
  };
}
