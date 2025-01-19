{ pkgs, lib, ... }:
pkgs.writeShellScriptBin "font-search" ''
  #!/usr/bin/env bash
  ${lib.getExe' pkgs.ontconfig "fc-list"} \
    | ${lib.getExe' pkgs.gnugrep "grep"} -ioE ": [^:]*$1[^:]+:" \
    | ${pkgs.gnused}/bin/sed -E 's/(^: |:)//g' \
    | ${lib.getExe' pkgs.uutils-coreutils-noprefix "tr"} , \\n \
    | ${lib.getExe' pkgs.uutils-coreutils-noprefix "sort"} \
    | ${lib.getExe' pkgs.uutils-coreutils-noprefix "uniq"}
''
