{ writeShellApplication, uutils-coreutils-noprefix, which, }:
writeShellApplication {
  name = "whereis-nix";

  text = ''
    readonly program_name="''${1:-}"

    if [[ -z "$program_name" ]]; then
        cat <<EOF
    usage: $(basename "$0") <name>

    Get where in /nix/store a program is located.
    EOF
        exit 1
    fi

    readlink -f "$(which "$program_name")"
  '';

  runtimeInputs = [ uutils-coreutils-noprefix which ];
}
# nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
