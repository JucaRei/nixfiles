{ config, lib, namespace, pkgs, ... }:
let
  inherit (lib) types;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.user;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  options.${namespace}.user = with types; {
    name = mkOpt str "juca" "The name of the user's account";
    initialPassword =
      mkOpt str "password"
        "The initial password to use";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions =
      mkOpt attrs { }
        "Extra options passed to users.users.<name>";
  };

  config = {
    # mkpasswd -m scrypt
    users.users.root.hashedPassword = "$7$CU..../....AXUF6bzPZ1a4TsoCIPh881$ixucvSm015l21tcWipVzgv1OJOlbyi4Nh0sobYnCqcB";
    users.mutableUsers = false;
    users.users.juca =
      {
        isNormalUser = true;
        inherit (cfg) name;
        hashedPassword = "$7$CU..../....0T5qGySa81GLu/J2mY8lU/$lQE8FwF9tVmQPJcDVBUgpVQMrtVzQt6gG4LBuBqXhV0";
        home = "/home/juca";
        group = "users";
        shell = pkgs.fish;
        extraGroups =
          [
            "audio"
            "input"
            "video"
            "wheel"
          ]
          ++ ifTheyExist [
            "docker"
            "git"
            "i2c"
            "kvm"
            "libvirtd"
            "libvirt"
            "libvirt-qemu"
            "network"
            "plugdev"
            "podman"
          ]
          ++ cfg.extraGroups;
      }
      // cfg.extraOptions;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
