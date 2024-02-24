{ hostname, lib, ... }: {
  services.xserver = if (hostname == "nitro") then {
    xkb = {
      layout = "br";
      variant = "abnt2";
      model = "pc105";
      options = "grp:alt_shift_toggle,caps:none";
    };
  } else {
    xkb = {
      layout = "us";
      variant = "mac";
      model = "pc105";
      options = "grp:alt_shift_toggle,caps:none";
    };
  };
}
