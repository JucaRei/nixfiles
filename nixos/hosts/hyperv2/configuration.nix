{ pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;

  system.stateVersion = "23.11"; # Did you read the comment?

  users.users."juca" = {
    isNormalUser = true;
    initialPassword = "200291";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };

  programs.fuse.userAllowOther = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "juca" = import ./home.nix;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # ----- Budgie Desktop Environment ----- #
  services.xserver = {
    enable = true;
    layout = "br";
    xkbVariant = "";
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "juca";
      lightdm.enable = true;
    };
    desktopManager.budgie.enable = true;
  };

  programs = {
    nano.syntaxHighlight = true;
    nano.nanorc = ''
      set atblanks
      set autoindent
      set boldtext
      set breaklonglines
      set casesensitive
      set constantshow
      set historylog
      set indicator
      set linenumbers
      set locking
      set matchbrackets "(<[{)>]}"
      set mouse
      set nonewlines
      set softwrap
      set tabsize 4
      set tabstospaces
      set trimblanks
      set titlecolor bold,white,magenta
      set promptcolor black,yellow
      set statuscolor bold,white,magenta
      set errorcolor bold,white,red
      set spotlightcolor black,orange
      set selectedcolor lightwhite,cyan
      set stripecolor ,yellow
      set scrollercolor magenta
      set numbercolor magenta
      set keycolor lightmagenta
      set functioncolor magenta
      extendsyntax python tabgives "    "
      extendsyntax makefile tabgives "  "
      bind ^X cut main
      bind ^C copy main
      bind ^V paste all
      bind ^Q exit all
      bind ^S savefile main
      bind ^F whereis all
      bind ^G findnext all
      bind ^R replace main
      unbind ^U all
      unbind ^N main
      unbind ^Y all
      unbind M-J main
      unbind M-T main
      bind ^Z undo main
    '';
  };

  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };
}
