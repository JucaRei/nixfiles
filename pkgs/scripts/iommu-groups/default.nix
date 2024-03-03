{ lib
, stdenv
, makeWrapper
, libvirt
, writeShellScript
, ...
}:

let
  iommuManipulation = writeShellScript "iommu-manipulation.sh" ''
    DIR="$(dirname -- $0)"
  
    if [ "$1" == "list" ]; then
        bash "$DIR/list-iommu-groups.sh"
        exit 0
    fi

    if [ "$1" == "attach" ]; then
        action="reattach"
    elif [ "$1" == "detach" ]; then
        action="detach"
    else
        echo "Unsupported action $1. Use list, attach or detach action.";
        exit 1;
    fi

    pci_addresses=$("$0" list | grep "IOMMU Group $2" | grep -Po "\d{2}:\d{2}\.\d{1}")
    sanatized_pci_addresses=''${pci_addresses//[:\.]/_}

    for pci_address in $sanatized_pci_addresses; do
        echo "IOMMU ''${action} pci_0000_''${pci_address}"

        if [[ "$@" == *"--test"* ]]; then
            echo "virsh nodedev-''${action} pci_0000_''${pci_address}"
        else
            virsh nodedev-''${action} pci_0000_''${pci_address}
        fi
    done
  '';
in
stdenv.mkDerivation rec {
  pname = "iommu-groups";
  version = "1.0.0";

  src = builtins.fetchurl {
    url = "https://gist.github.com/techhazard/1be07805081a4d7a51c527e452b87b26/raw/e41403996a1da85ada2735f636b35ab5c4b4764a/ensuring_iommu_groups_are_valid.sh";
    sha256 = "081xqby8wg7i8mp4n91jwbqiq9sb2730l21dpnxvl2abcqs12dz3";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/list-iommu-groups.sh
    cp ${iommuManipulation} $out/share/iommu-manipulation.sh
    chmod +x $out/share/iommu-manipulation.sh
    
    makeWrapper $out/share/iommu-manipulation.sh $out/bin/iommu-groups
  '';
}
