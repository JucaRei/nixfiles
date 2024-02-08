{ pkgs ? import <nixpkgs> { } }:
(pkgs.buildFHSUserEnv {
  name = "pipzone";
  targetPkgs = pkgs:
    (with pkgs; [ python39 python39Packages.pip python39Packages.virtualenv ]);
  multiPkgs = pkgs: with pkgs; [ libgcc binutils coreutils ];
  profile = ''
    export LIBRARY_PATH=/usr/lib:/usr/lib64:$LIBRARY_PATH
    # export LIBRARY_PATH=${pkgs.libgcc}/lib # this may also works, not tested
  '';
  runScript = "bash";
}).env
