{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.system.documentation;
in
{
  options = {
    system.documentation = {
      enable = mkEnableOption "Enable default documentation.";
      doctypes = mkOption {
        type = types.listOf (types.enum [ "nixos" "man" "info" "doc" ]);
        default = [ ];
        description = "Enables selected docs.";
      };
    };
  };

  config = mkIf cfg.enable {
    documentation = {
      enable = true;
      nixos.enable = mkIf cfg.doctypes == "nixos";
      man.enable = mkIf cfg.doctypes == "man";
      info.enable = mkIf cfg.doctypes == "info";
      doc.enable = mkIf cfg.doctypes == "doc";
    };
  };
}
