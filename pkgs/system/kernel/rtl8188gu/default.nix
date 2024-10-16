{ stdenv, lib, fetchFromGitHub, kernel, bc }:

let modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtl8188gu";

in stdenv.mkDerivation rec {
  name = "r8188gu-${kernel.version}-${version}";
  # on update please verify that the source matches the realtek version
  version = "1.0.1";

  src = fetchFromGitHub {
    # owner = "JucaRei";
    # repo = "RTL8188GU";
    # rev = "36ad61c1d93981bd5289114af623d18e49307826";
    # sha256 = "sha256-D2A8s4yVBLAs6FWRG36lHzzPz8mCsBtLMJuwWLpx3NM=";

    owner = "wandercn";
    repo = "RTL8188GU";
    rev = "f9944c51911d851bb214a56ea0c4fc11059f6bf8";
    hash = "sha256-HVwuofQqTpo6GMtw8Orx3YsfEAfDIbYfejlDbJh3ZU0=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ bc ];

  preBuild = ''
    makeFlagsArray+=("KVER=${kernel.modDirVersion}")
    makeFlagsArray+=("KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build")
    makeFlagsArray+=("modules")

    # try to make it work for v5.8 - but update_mgmt_frame_registrations is too different
    #find -type f -exec sed -i 's/sha256_/rtl_sha256_/g ; s/timespec/timespec64/ ; s/getboottime/getboottime64/ ; s/mgmt_frame_register/update_mgmt_frame_registrations/g' {} \+
    find -type f -exec sed -i 's/timespec/timespec64/ ; s/getboottime/getboottime64/ ; s/entry = proc_create_data.*/entry = NULL;/' {} \+
  '';

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p ${modDestDir}
    find . -name '*.ko' -exec cp --parents '{}' ${modDestDir} \;
    find ${modDestDir} -name '*.ko' -exec xz -f '{}' \;
  '';

  meta = with lib; {
    description = "Realtek RTL8188GU driver";
    longDescription = ''
      A kernel module for Realtek 8188gu usb network card.
    '';
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };

}


# { stdenv, lib, fetchFromGitHub, linux }:
# stdenv.mkDerivation rec {
#   version = "1.0.1";
#   pname = "rtl8188gu-${linux.version}";

#   src = fetchFromGitHub {
#     owner = "JucaRei";
#     repo = "RTL8188GU";
#     rev = "36ad61c1d93981bd5289114af623d18e49307826";
#     sha256 = "sha256-D2A8s4yVBLAs6FWRG36lHzzPz8mCsBtLMJuwWLpx3NM=";
#   };

#   sourceRoot = "source";

#   kernelVersion = linux.modDirVersion;
#   modules = [ "8188gu" ];
#   makeFlags = [
#     "-C"
#     "${linux.dev}/lib/modules/${linux.modDirVersion}/build"
#     "modules"
#     "CROSS_COMPILE=${linux.stdenv.cc.targetPrefix or ""}"
#     "M=$(NIX_BUILD_TOP)/$(sourceRoot)"
#     "VERSION=$(version)"
#     "CONFIG_RTL8188GU=m"
#   ] ++ (if linux.stdenv.hostPlatform ? linuxArch then [
#     "ARCH=${linux.stdenv.hostPlatform.linuxArch}"
#   ] else [ ]);
#   enableParallelBuilding = true;

#   installPhase = ''
#     install -Dm644 -t $out/lib/modules/$kernelVersion/kernel/drivers/net/wireless 8188gu.ko
#   '';

#   meta.platforms = lib.platforms.linux;
# }
