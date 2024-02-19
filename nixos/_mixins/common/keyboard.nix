{ hostname, lib, ... }: {
  services.xserver = if (hostname == "nitro") then {
    layout = "br";
    xkb = {
      variant = "abnt2";
      model = "pc105";
      options = "grp:alt_shift_toggle,caps:none";
    };
  } else {
    layout = "us";
    xkb = {
      variant = "mac";
      model = "pc105";
      options = "grp:alt_shift_toggle,caps:none";
    };
  };
}
