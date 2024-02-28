{
  pkgs,
  lib,
  hostname,
  ...
}: {
  ###################
  ### Console tty ###
  ###################

  console = {
    # keyMap = lib.mkForce (if (hostname == "nitro") then "br" else "us");
    #earlySetup = true;
    font =
      lib.mkForce
      "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    colors = [
      "1b161f"
      "ff5555"
      "54c6b5"
      "d5aa2a"
      "bd93f9"
      "ff79c6"
      "8be9fd"
      "bfbfbf"

      "1b161f"
      "ff6e67"
      "5af78e"
      "ffce50"
      "caa9fa"
      "ff92d0"
      "9aedfe"
      "e6e6e6"
    ];
    packages = with pkgs; [tamzen];
  };

  services.getty.greetingLine = lib.mkForce "\\l";
  services.getty.helpLine = lib.mkForce ''
    Type `i' to print system information.

    .     .       .  .   . .   .   . .    +  .
      .     .  :     .    .. :. .___---------___.
           .  .   .    .  :.:. _".^ .^ ^.  '.. :"-_. .
        .  :       .  .  .:../:            . .^  :.:\.
            .   . :: +. :.:/: .   .    .        . . .:\
     .  :    .     . _ :::/:               .  ^ .  . .:\
      .. . .   . - : :.:./.                        .  .:\
      .      .     . :..|:                    .  .  ^. .:|
        .       . : : ..||        .                . . !:|
      .     . . . ::. ::\(                           . :)/
     .   .     : . : .:.|. ######              .#######::|
      :.. .  :-  : .:  ::|.#######           ..########:|
     .  .  .  ..  .  .. :\ ########          :######## :/
      .        .+ :: : -.:\ ########       . ########.:/
        .  .+   . . . . :.:\. #######       #######..:/
          :: . . . . ::.:..:.\           .   .   ..:/
       .   .   .  .. :  -::::.\.       | |     . .:/
          .  :  .  .  .-:.":.::.\             ..:/
     .      -.   . . . .: .:::.:.\.           .:/
    .   .   .  :      : ....::_:..:\   ___.  :/
       .   .  .   .:. .. .  .: :.:.:\       :/
         +   .   .   : . ::. :.:. .:.|\  .:/|
         .         +   .  .  ...:: ..|  --.:|
    .      . . .   .  .  . ... :..:.."(  ..)"
     .   .       .      :  .   .: ::/  .  .::\
  '';
}
