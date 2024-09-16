{ config, username }: {
  defaultEditor = "micro";
  flake-path = "/home/${username}/.dotfiles/nixfiles";

  keymap = "br-abnt2";

  # Keyboard
  layout = "br";
  variant = "abnt2";
  xkboptions = "terminate:ctrl_alt_bksp";
  model = "pc105";

  timezone = "America/Sao_Paulo";
}
