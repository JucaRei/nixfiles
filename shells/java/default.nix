{ mkShell, pkgs, ... }:
mkShell {
  packages = with pkgs; [
    jdk
    jdk8
    jdk11
    jdk17
    temurin-jre-bin-17
    maven
    gradle

    figlet
    lolcat
  ];

  shellHook = ''

    echo "🔨 Java DevShell" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300


  '';
}
