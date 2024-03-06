{
  description = "getting started example";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default =
        let
          pkgs = import nixpkgs {
            inherit system;

            overlays = [ devshell.overlays.default ];
          };

          randomFiglet = pkgs.writeShellScript "randomFiglet" ''
            phrases=("Nix Your Problems Away!" "One Flake to Rule Them All!" "Why Fix It, When You Can Nix It?" "Nixify Life" "Just Nix It" "Powered by Nix")
            random_index=$((RANDOM % 6))
            case $random_index in
              0) ${pkgs.figlet}/bin/figlet "Nixify Life";;
              1) ${pkgs.figlet}/bin/figlet "Just Nix It";;
              2) ${pkgs.figlet}/bin/figlet "Powered by Nix";;
              3) ${pkgs.figlet}/bin/figlet "Nix Your Problems Away!";;
              4) ${pkgs.figlet}/bin/figlet "One Flake to Rule Them All!";;
              5) ${pkgs.figlet}/bin/figlet "Why Fix It, When You Can Nix It?";;
            esac
          '';
        in
        pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          name = "basic-shell";
          motd = ''
            {214}👁️  Welcome to a Basic devshell 👁️{reset}
            $( ${randomFiglet} | ${pkgs.lolcat}/bin/lolcat -f )
            $(type -p menu &>/dev/null && menu)
          '';
          commands = [ ];
          env = [
            {
              name = "LD_LIBRARY_PATH";
              value = "${pkgs.gcc.cc.lib}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH";
            }
          ];
        };
    });
}
