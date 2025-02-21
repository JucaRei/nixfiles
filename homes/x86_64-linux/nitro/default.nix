{ lib, pkgs, config, osConfig ? { }, format ? "unknown", namespace, ... }:
with lib.${namespace};
{
  excalibur = { };
}
