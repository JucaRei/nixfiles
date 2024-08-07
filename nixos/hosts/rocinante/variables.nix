{ config, username }: {
  defaultEditor = "micro";
  flake-path = "/home/${username}/.dotfiles/nixfiles";

  df-locale = "en_US.utf8";
  extra-locale = "pt_BR.UTF-8";
  keymap = "br-abnt2";

  # Keyboard
  layout = "us";
  variant = "mac";
  xkboptions = "terminate:ctrl_alt_bksp";
  model = "pc105";

  timezone = "America/Sao_Paulo";
  dbus-type = "dbus";
}
