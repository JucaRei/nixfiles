{pkgs ? import <nixpkgs> {}}:
with pkgs; let
  goVersion = "1_19";
in
  mkShell {
    buildInputs = [go_1_19 golint gofumpt gotools protobuf protoc-gen-go nodejs-slim];

    postBuild = ''
      # Run `go install` to install the `sqlc` tool
      go install github.com/kyleconroy/sqlc/cmd/sqlc
    '';
  }
# nix-shell go-node-shell.nix

