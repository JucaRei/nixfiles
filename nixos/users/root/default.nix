_: {
  users.users.root = {
    # hashedPassword = null;
    # Default password = "pass"
    hashedPassword = "$6$S6BR/UEFw5NfIRsv$iu/ASjgMHYqMaCNK0muYGLv1fD2/W5J2BSxejYNUD4FWDugnN3MFmw5RekvAee2DsbwzB9tyoXitF8RJTGDrX1"; # changeMe when installed
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrd5yF/0aMECHqkM1oNrOX5QBQ4sYbkiNR15XzBGkUU Reinaldo P Jr"
    ];
  };
}
