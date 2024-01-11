{ pkgs, ... }: {
  boot = {
    # Appimage Registration
    binfmt.registrations.appimage = {
      # make appImage work seamlessly
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      # mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
      magicOrExtension = "\\x7fELF....AI\\x02";
      # magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}
