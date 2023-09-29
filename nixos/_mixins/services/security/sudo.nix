{ username, lib, pkgs, ... }:
let
  groot_text = ''

      \033[00;32m  \\^V//
      \033[00;33m  |\033[01;37m. \033[01;37m.\033[00;33m|   \033[01;34m  I am (G)root!
      \033[00;32m- \033[00;33m\\ - / \033[00;32m_
      \033[00;33m \\_| |_/
      \033[00;33m   \\ \\
      \033[00;31m __\033[00;33m/\033[00;31m_\033[00;33m/\033[00;31m__
      \033[00;31m|_______|  \033[00;37m With great power comes great responsibility.
      \033[00;31m \\     /   \033[00;37m Use sudo wisely.
      \033[00;31m  \\___/
    \033[0m
  '';
in
{

  # copied from this Gist https://gist.github.com/nikopol/9e9409b0d1a6cd2ed7e89be1849e0724
  environment.etc."sudoers.d/00-lecture.txt".source = pkgs.stdenv.mkDerivation {
    name = lib.strings.sanitizeDerivationName "sudoers.d/00-lecture.txt";
    buildCommand = "echo -e '${groot_text}' > $out";
  };

  security = {
    sudo = {
      enable = lib.mkDefault true;
      # Stops sudo from timing out.
      extraConfig = ''
        # ${username} ALL=(ALL) NOPASSWD:ALL
        Defaults env_reset,timestamp_timeout=-1
        Defaults 	insults
      '';
      configFile = ''
        Defaults lecture = always
        Defaults lecture_file=/etc/sudoers.d/00-lecture.txt
      '';
      execWheelOnly = true;
      wheelNeedsPassword = true;
    };
  };
}
