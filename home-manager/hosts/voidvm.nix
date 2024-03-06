{lib, ...}:
with lib.hm.gvariant; {
  imports = [../_mixins/apps/text-editor/vscode.nix];
  # services.xserver.enable = true;
  # xsession = {
  #   enable = true;
  #   windowManager.command = "...";
  # };
}
