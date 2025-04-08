{ pkgs, polybar, cava, ... }:
pkgs.writeShellApplication {
  name = "cava-polybar";
  runtimeInputs = [ polybar cava ];
  text = builtins.readFile ./cava.sh;
}
