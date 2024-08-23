{ mkShell, pkgs, ... }:
mkShell {
  packages = with pkgs; [
    cargo
    clippy
    rust-analyzer
    rustc
    rustfmt

    figlet
    lolcat
  ];

  shellHook = ''

    echo "🔨 Rust DevShell" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300


  '';
}
