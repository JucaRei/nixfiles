{ pkgs, lib, config, ... }@args:
with lib;
let
  nixgl = import ../../../../../lib/nixGL.nix { inherit config pkgs; };
  codegl = nixGL pkgs.unstable.vscode;
  cfg = config.services.vscode;

  isGeneric = if (config.targets.genericLinux.enable) then true else false;
in
{
  imports = [
    ### Enable immutable vscode settings
    # ../../../config/vscode/settings.nix
    # ./vscode-remote # import this if you want vscode server
  ];

  # enable vs-code remote

  config = {
    # services.vscode-server.enable = lib.mkDefault false; # true
    programs.vscode = {
      enable = true;
      # package = pkgs.unstable.vscode;
      package = if (isGeneric) then (nixgl pkgs.unstable.vscode) else pkgs.unstable.vscode;

      mutableExtensionsDir = true;
      enableUpdateCheck = false;

      userSettings = import ../../../config/vscode/settings.nix args;

      extensions = with pkgs.unstable.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
        oderwat.indent-rainbow
        formulahendry.code-runner
        davidanson.vscode-markdownlint
        editorconfig.editorconfig
        redhat.vscode-yaml
        ms-python.python
        sumneko.lua
        # ms-vscode-remote.remote-containers
        # ms-vscode-remote.vscode-remote-extensionpack

        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-containers
      ]
      # ++ pkgs.unstable.vscode-extensions.ms-vscode-remote [
      #ms-azuretools.vscode-docker ## Downgrade to 1.22
      # ]
      ++ pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
        # {
        # ms-azuretools.vscode-docker
        # v1.22.2
        # name = "vscode-docker";
        # publisher = "ms-azuretools";
        # version = "1.28.0";
        # sha256 = "sha256-ACaVwRTN4lu97GDGzxyzX/O10p6fNT3FNLne/todrFo=";
        # version = "v1.22.2"; # ## Downgrade make it work with podman
        # sha256 = "sha256-sRvd9M/gF4kh4qWxtS1xKKIvqg9hRJpRl/p/FYu2TI8=";
        # }
        {
          name = "better-nix-syntax";
          publisher = "jeff-hykin";
          version = "1.1.5";
          sha256 = "sha256-9V+ziWk9V4LyQiVNSC6DniJDun+EvcK30ykPjyNsvp0=";
        }
        {
          name = "color-highlight-css-color-4";
          publisher = "Yunduo";
          version = "1.1.3";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-2/x078M1wi4/F9aVpHQTgWKdDnEHqXKea+tsNw7YyBo=";
        }
        {
          name = "macos-modern-theme";
          publisher = "davidbwaters";
          version = "2.3.19";
          sha256 = "sha256-/gpGu3vvomQA0TC+TBJkBe2AFWimIyiMM5fndYF8G/A=";
        }
        {
          name = "color-picker";
          publisher = "MarkosTh09";
          version = "1.0.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-28tSGWdtQVu0I34DQBl1CicEqQHP37dS//FH9sTaECY=";
        }
        {
          name = "simple-icons";
          publisher = "Comdec";
          version = "0.1.6";
          sha256 = "sha256-OSsVdJyG7Mi4ltza40LvmyDZF/hMmVZENfJkaBzVcWw=";
        }
        {
          # name = "vscode-projects";
          name = "l13-projects";
          publisher = "L13RARY"; # L13RARY.l13-projects
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
        {
          name = "shell-format";
          publisher = "foxundermoon";
          version = "7.2.5";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-kfpRByJDcGY3W9+ELBzDOUMl06D/vyPlN//wPgQhByk=";
        }
        {
          name = "separators";
          publisher = "alefragnani";
          version = "2.6.1";
          sha256 = "sha256-JTFD6TGt4C3ctm+2ckTzqje2M/SiK7xshr1Hf9rQkFA=";
        }
        {
          name = "vscode-thunder-client";
          publisher = "rangav";
          version = "2.24.11";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-peHWih/LtMRqjkqW6ObFRpOy2YzgjPSC+nhCtDS3B9A=";
        }
        {
          name = "reload";
          publisher = "natqe";
          version = "0.0.7";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-j0Dj7YiawhPAMHe8wk8Ph4vo26IneidoGJ4C9O7Z/64=";
        }
        {
          name = "git-graph";
          publisher = "mhutchie";
          version = "1.30.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-sHeaMMr5hmQ0kAFZxxMiRk6f0mfjkg2XMnA4Gf+DHwA=";
        }
        {
          name = "codesnap";
          publisher = "adpyke";
          version = "1.3.4";
          sha256 = "sha256-dR6qODSTK377OJpmUqG9R85l1sf9fvJJACjrYhSRWgQ=";
        }
        # {
        #   name = "remote-ssh";
        #   publisher = "ms-vscode-remote";
        #   version = "0.111.2024032515";
        #   # sha256 = lib.fakeSha256;
        #   sha256 = "sha256-MZ0ntoB20xTum+WQSwc29JS1UINoxImyU0orGzN0IP0=";
        # }
        # {
        #   name = "remote-containers";
        #   publisher = "ms-vscode-remote";
        #   version = "0.352.0";
        #   # sha256 = lib.fakeSha256;
        #   sha256 = "sha256-bLkMJcC4IS9fAIzEKBtjUkqAzKQUGrGpp/LR1Ak81A4=";
        # }
        # {
        #   name = "vscode-remote-extensionpack";
        #   publisher = "ms-vscode-remote";
        #   version = "0.25.0";
        #   # sha256 = lib.fakeSha256;
        #   sha256 = "sha256-CleLZvH40gidW6fqonZv/E/VO8IDI+QU4Zymo0n35Ns=";
        # }
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
          version = "1.18.0";
          sha256 = "sha256-m8utv500Xk6jLI5ndNfiOoPZfyJcLC2XuNwLdC9J+6w=";
        }
        {
          name = "linux-desktop-file";
          publisher = "nico-castell";
          version = "0.0.21";
          sha256 = "sha256-4qy+2Tg9g0/9D+MNvLSgWUE8sc5itsC/pJ9hcfxyVzQ=";
        }
        {
          name = "red-theme";
          publisher = "RedCrafter07";
          version = "0.0.3";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-zGQaQDusiEhuvqGd5AqSpTYKpuaGR2WJr5XpPbESzeU=";
        }
      ];
    };

    ### Wayland
    # xdg = {
    #   desktopEntries = {
    #     codium = {
    #       name = "VSCodium";
    #       type = "Application";
    #       categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    #       comment = "Code Editing. Redefined.";
    #       exec = ''sh -c "LD_LIBRARY_PATH=\\$NIX_LD_LIBRARY_PATH codium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WaylandWindowDecorations"'';
    #       genericName = "Text Editor";
    #       icon = "vscodium";
    #       mimeType = [ "x-scheme-handler/vscode" ];
    #       noDisplay = false;
    #       startupNotify = true;
    #       terminal = false;
    #     };
    #   };
    # };
  };
}
