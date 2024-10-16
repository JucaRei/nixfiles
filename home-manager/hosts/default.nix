{ lib, hostname, ... }: {
  imports = lib.optional (builtins.pathExists (./. + "/${hostname}")) ./${hostname};
}
