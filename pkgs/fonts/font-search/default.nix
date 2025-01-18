{ writeShellScriptBin, lib, fontconfig, gnugrep, gnused, uutils-coreutils-noprefix, ... }:
writeShellScriptBin "font-search" ''
  #!/usr/bin/env bash
  ${lib.getExe' fontconfig "fc-list"} \
    | ${lib.getExe' gnugrep "grep"} -ioE ": [^:]*$1[^:]+:" \
    | ${gnused}/bin/sed -E 's/(^: |:)//g' \
    | ${lib.getExe' uutils-coreutils-noprefix "tr"} , \\n \
    | ${lib.getExe' uutils-coreutils-noprefix "sort"} \
    | ${lib.getExe' uutils-coreutils-noprefix "uniq"}
''
