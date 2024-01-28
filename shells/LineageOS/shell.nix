# I used this shell.nix to build LineageOS 13.0 for my maguro (Samsung Galaxy Nexus GSM) phone
# The build instructions for normal Linuxes are here: https://wiki.lineageos.org/devices/maguro/build
# For NixOS, follow those instructions but skip anything related to installing packages
# Detailed instructions:
#   cd into an empty directory of your choice
#   copy this file there
#   in nix-shell:
#    $ repo init -u https://github.com/LineageOS/android.git -b cm-13.0
#    $ repo sync
#    $ source build/envsetup.sh
#    $ breakfast maguro
#    Get proprietary blobs (see https://wiki.lineageos.org/devices/maguro/build#extract-proprietary-blobs)
#     (I actually used blobs from https://github.com/TheMuppets, following https://forum.xda-developers.com/showpost.php?s=a6ee98b07b1b0a2f4004b902a65d9dcd&p=76981184&postcount=4)
#    $ ccache -M 50G (see https://wiki.lineageos.org/devices/maguro/build#turn-on-caching-to-speed-up-build)
#    $ croot
#    $ brunch maguro
#    $ cd $OUT
#   The built ROM is named something like lineage-13.0-20180730-UNOFFICIAL-maguro.zip
#   You can flash it onto your device as usual, see e.g. https://wiki.lineageos.org/devices/maguro/install for maguro
#   Voilà ! It Just Works™ (at least it did for me)
# Warning: the hardened NixOS kernel disables 32 bit emulation, which made me run into multiple "Exec format error" errors.
# To fix, use the default kernel, or enable "IA32_EMULATION y" in the kernel config.
let
  # nixpkgs-unstable does not have jdk7 anymore. I used the nixos-18.03 channel
  pkgs = import <nixpkgs> { };

  # Inspired from https://nixos.wiki/wiki/Android#Building_Android_on_NixOS
  # I had to add several packages to make it work for me
  fhs = pkgs.buildFHSUserEnv {
    name = "android-env";
    targetPkgs = pkgs:
      with pkgs; [
        androidenv.platformTools
        bc
        binutils
        bison
        ccache
        curl
        flex
        gcc
        git
        gitRepo
        gnumake
        gnupg
        gperf
        imagemagick
        jdk7
        libxml2
        lz4
        lzop
        m4
        maven # Needed for LineageOS 13.0
        nettools
        openssl
        perl
        pngcrush
        procps
        python2
        rsync
        schedtool
        SDL
        squashfsTools
        unzip
        utillinux
        wxGTK30
        xml2
        zip
      ];
    multiPkgs = pkgs: with pkgs; [ zlib ncurses5 libcxx readline ];
    runScript = "bash";
    profile = ''
      export USE_CCACHE=1
      export ANDROID_JAVA_HOME=${pkgs.jdk19_headless.home}
      # Building involves a phase of unzipping large files into a temporary directory
      export TMPDIR=/tmp
    '';
  };
in pkgs.stdenv.mkDerivation {
  name = "android-env-shell";
  nativeBuildInputs = [ fhs ];
  shellHook = "exec android-env";
}
### Building LineageOS on NixOS

