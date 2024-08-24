{ config
, lib
, namespace
, ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.security.pam;
in
{
  options.${namespace}.security.pam = {
    enable = mkBoolOpt false "Whether or not to configure pam.";
  };

  config = mkIf cfg.enable {
    security.pam.loginLimits = [
      {
        domain = "*";
        item = "nofile";
        type = "-";
        value = "65536";
      }

      # Increase open file limit for sudoers
      # fix "too many files open" errors while writing a lot of data at once
      # (e.g. when building a large package)
      # if this, somehow, doesn't meet your requirements you may just bump the numbers up

      # {
      #   domain = "@wheel";
      #   item = "nofile";
      #   type = "soft";
      #   value = "524288";
      # }
      # {
      #   domain = "@wheel";
      #   item = "nofile";
      #   type = "hard";
      #   value = "1048576";
      # }
    ];
  };
}
