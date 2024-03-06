{lib, ...}: {
  home = {
    file = {
      ".Xresources" =
        lib.mkForce {text = "Xcursor.theme: Bibata-Modern-Ice";};
    };
  };
}
