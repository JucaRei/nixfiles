# {{ lib, namespace }:
# with lib;
# with (lib.${namespace}).mkOpt;
# {
#   options.${namespace}.programs.terminal.tools.ssh = mkOption {
#     enable = mkBoolOpt false "Whether or not to configure ssh support.";
#     extraConfig = mkOpt str "" "Extra configuration to apply.";
#     port = mkOpt port 2222 "The port to listen on (in addition to 22).";
#   };

#   config = mkIf cfg.enable {
#     programs = {
#       ssh = {
#         enable = true;
#         compression = true;
#         forwardAgent = true;
#         controlMaster = "auto";
#       };
#     };
#   };
# }
{ }
