_: {
  users.users.root = {
    group = "root";
    # hashedPassword = null;
    # Default password = "pass"
    hashedPassword = "$6$S6BR/UEFw5NfIRsv$iu/ASjgMHYqMaCNK0muYGLv1fD2/W5J2BSxejYNUD4FWDugnN3MFmw5RekvAee2DsbwzB9tyoXitF8RJTGDrX1"; # changeMe when installed
    openssh.authorizedKeys.keys = [ ];
  };
}
