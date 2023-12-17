args@{ pkgs, lib ? pkgs.lib, config, ... }:
let

  nixGL = import ../../../../lib/nixGL.nix { inherit config pkgs; };

  codegl = pkgs.unstable.vscode;

  # nixGLVulkanMesaWrap = pkg:
  #   pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
  #     mkdir $out
  #     ln -s ${pkg}/* $out
  #     rm $out/bin
  #     mkdir $out/bin
  #     for bin in ${pkg}/bin/*; do
  #       wrapped_bin=$out/bin/$(basename $bin)
  #       echo "${lib.getExe pkgs.nixgl.nixGLIntel} ${
  #         lib.getExe pkgs.nixgl.nixVulkanIntel
  #       } $bin \$@" > $wrapped_bin
  #       chmod +x $wrapped_bin
  #     done
  #   '';

  # nixGL = (import
  #   (builtins.fetchGit {
  #     url = "http://github.com/guibou/nixGL";
  #     ref = "refs/heads/main";
  #   })
  #   { enable32bits = false; }).auto;

in
{
  imports = [
    ### Enable immutable vscode settings
    # ../../config/vscode/settings.nix
  ];
  programs.vscode = {
    enable = true;
    # package = pkgs.unstable.vscode;
    # package = pkgs.vscodium-fhs;
    # package = (nixGL pkgs.vscode.override {
    #   commandLineArgs = builtins.concatStringsSep " " [
    #     "--enable-wayland-ime"
    #     "--ozone-platform-hint=auto"
    #   ];
    # });
    package = (nixGL codegl);

    mutableExtensionsDir = true;
    enableUpdateCheck = false;

    extensions =
      with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        # brettm12345.nixfmt-vscode
        oderwat.indent-rainbow
        # catppuccin.catppuccin-vsc-icons
        formulahendry.code-runner
        davidanson.vscode-markdownlint
        editorconfig.editorconfig
        redhat.vscode-yaml
        ms-python.python
        ms-azuretools.vscode-docker
        sumneko.lua
        # ms-vscode-remote.remote-containers
        # ms-vscode-remote.vscode-remote-extensionpack
      ]
      ++ pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "Rasi";
          publisher = "dlasagno";
          version = "1.0.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-s60alej3cNAbSJxsRlIRE2Qha6oAsmcOBbWoqp+w6fk=";
        }
        # {
        #   name = "codeium";
        #   publisher = "Codeium";
        #   version = "1.5.9";
        #   sha256 = "sha256-6PLn7g/znfc2uruYTqxQ96IwXxfz6Sbguua3YqZd64U=";
        # }
        {
          name = "better-nix-syntax";
          publisher = "jeff-hykin";
          version = "1.0.7";
          sha256 = "sha256-vqfhUIjFBf9JvmxB4QFrZH4KMhxamuYjs5n9VyW/BiI=";
        }
        {
          name = "color-highlight-css-color-4";
          publisher = "Yunduo";
          version = "1.1.3";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-2/x078M1wi4/F9aVpHQTgWKdDnEHqXKea+tsNw7YyBo=";
        }
        {
          name = "bootstrap-product-icons";
          publisher = "RubenVerg";
          version = "1.0.2";
          sha256 = "sha256-u7Vw+LJyHZ+ohC/R4ETmJD07/NEkNDUeQh8v5U1YAgk=";
        }
        {
          name = "material-product-icons";
          publisher = "PKief";
          version = "1.7.0";
          sha256 = "sha256-F6sukBQ61pHoKTxx88aa8QMLDOm9ozPF9nonIH34C7Q=";
        }
        {
          name = "vscode-lua";
          publisher = "trixnz";
          version = "0.12.4";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-cuXSsQlcvghylZamk4HajlAhrKZ8uRG3PBsA43dEBJg=";
        }
        {
          name = "color-picker";
          publisher = "MarkosTh09";
          version = "1.0.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-28tSGWdtQVu0I34DQBl1CicEqQHP37dS//FH9sTaECY=";
        }
        {
          name = "vscode-icons";
          publisher = "vscode-icons-team";
          version = "12.5.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-PrOakITVBJKaGqlhbWNSY2eh4R8fiBd2hEdWzN3lCjs=";
        }
        {
          # name = "vscode-projects";
          name = "l13-projects";
          publisher = "L13RARY";  #L13RARY.l13-projects
          # publisher = "l13";
          version = "1.1.1";
          sha256 = "sha256-HVlnHzIxRZbTXu0zg9DXUAXaydmQaIt9H4ZYmmrniR0=";
        }
        {
          name = "vscode-status-bar-format-toggle";
          publisher = "tombonnike";
          version = "3.2.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-MuDOhp6Ur5iwzHjyK7qEVSGOQovfWPwwYJ0Sl/RsIQE=";
        }
        # {
        #   name = "shell-format";
        #   publisher = "foxundermoon";
        #   version = "7.2.5";
        #   # sha256 = lib.fakeSha256;
        #   sha256 = "sha256-kfpRByJDcGY3W9+ELBzDOUMl06D/vyPlN//wPgQhByk=";
        # }
        {
          name = "vscode-thunder-client";
          publisher = "rangav";
          version = "2.13.5";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-EkwhzeNVOsaXv3Fmox3yGacw0PxlfHVysWyTG7iPRrg=";
        }
        {
          name = "reload";
          publisher = "natqe";
          version = "0.0.6";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-bTFLk3sCJb7ztkC/Cxci6n7RbcyNjEYNKREUf9wDQRU=";
        }
        {
          name = "git-graph";
          publisher = "mhutchie";
          version = "1.30.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-sHeaMMr5hmQ0kAFZxxMiRk6f0mfjkg2XMnA4Gf+DHwA=";
        }
        {
          name = "unfoldai";
          publisher = "TalDennis-UnfoldAI-ChatGPT-Copilot";
          version = "0.2.6";
          sha256 = "sha256-W+glLyrRtdoxRnHRKIQftJBTT6GJZ1SemAYTgqgSXt4=";
        }
        {
          name = "polacode-2019";
          publisher = "jeff-hykin";
          version = "0.6.1";
          sha256 = "sha256-SbfsD28gaVHAmJskUuc1Q8kA47jrVa3OO5Ur7ULk3jI=";
        }
        {
          name = "remote-ssh";
          publisher = "ms-vscode-remote";
          version = "0.107.2023100615";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-pRdcEyApccS+A/8zgmzM3wSJcBx2P/BAK2ggbO2v4+A=";
        }
        {
          name = "remote-containers";
          publisher = "ms-vscode-remote";
          version = "0.318.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-mhNp7mAxcf/3wMeMTMiYyEtlY+KgSx9BZutTdtgB5dY=";
        }
        {
          name = "vscode-remote-extensionpack";
          publisher = "ms-vscode-remote";
          version = "0.24.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-6v4JWpyMxqTDIjEOL3w25bdTN+3VPFH7HdaSbgIlCmo=";
        }
        {
          name = "darker-plus-material-red";
          publisher = "chireia";
          version = "1.0.2";
          # sha256 = lib.fakeSha256; ### if you trust
          sha256 = "sha256-YT8g6hA4Cs0EGan+d3iIKVh/fZm10/DcOxYiiEXEeYc=";
        }
        {
          name = "beardedicons";
          publisher = "beardedbear";
          version = "1.13.2";
          sha256 = "sha256-PpIut/yhUNK1eTPRvVXONt06TOXpoGgmd6lrhFdADRQ";
        }
        {
          name = "linux-desktop-file";
          publisher = "nico-castell";
          version = "0.0.21";
          sha256 = "sha256-4qy+2Tg9g0/9D+MNvLSgWUE8sc5itsC/pJ9hcfxyVzQ=";
        }
        {
          name = "pork-and-beans";
          publisher = "HighSpeedDirt";
          version = "0.9.2";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-ErBbNPTxTbhQYkxuh3K9kEfkFvG35y/vuylsFPnlOtg=";
        }
        {
          name = "red-theme";
          publisher = "RedCrafter07";
          version = "0.0.2";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-JLxVOPNJEythpA8K1aa/d1TcG1rWfV4yMl3bcXCu+KE=";
        }
        #   {
        #     name = "gamberetti-reborn-theme";
        #     publisher = "dSyncro";
        #     version = "1.0.0";
        #     # sha256 = lib.fakeSha256;
        #     sha256 = "sha256-cRiwx6ELRnHIqobBwYkrZXnptue/+M9bDKvonhQ8hj4=";
        #   }
        # {
        #   name = "catppuccin-perfect-icons";
        #   publisher = "thang-nm";
        #   # sha256 = lib.fakeSha256;
        #   sha256 = "sha256-S9s+CQWu3ADRW0J7BPxTTypwMOmpzmdeXcZcSVHXPyU=";
        # }
        # {
        #   publisher = "zguolee";
        #   name = "tabler-icons";
        #   version = "0.2.2";
        #   sha256 = "UxMjXwfL9YMb7nGH41LoAu9R3b4dWdK66+w0tfGy8Lk=";
        # }
      ];
  };
  # home.packages = lib.mkMerge [
  # [ ... ]
  # (lib.mkIf (args ? "nixosConfig") [ ... ])
  # ];

  # Only if is non-nixos system
  xdg.desktopEntries = lib.mkIf (args ? "nixosConfig") {
    code = {
      categories = [ "Utility" "TextEditor" "Development" "IDE" ];
      comment = "Code Editing. Redefined.";
      exec = "${nixGL.nixGLDefault}/bin/nixGL ${pkgs.vscode}/bin/code %F";
      genericName = "Text Editor";
      icon = "${pkgs.vscode}/share/pixmaps/vscode.png";
      mimeType = [ "text/plain" "inode/directory" ];
      name = "Visual Studio Code";
      startupNotify = true;
      type = "Application";
    };
  };
}
