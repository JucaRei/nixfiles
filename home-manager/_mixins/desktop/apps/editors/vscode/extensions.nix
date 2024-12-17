{ pkgs, ... }:
let
  packagedExtensions = with pkgs.unstable.vscode-extensions; [
    # Python
    ms-python.python

    # All the Catppuccin theme options are available as overrides
    # (catppuccin.catppuccin-vsc.override {
    #   accent = "blue";
    #   boldKeywords = true;
    #   italicComments = true;
    #   italicKeywords = true;
    #   extraBordersEnabled = false;
    #   workbenchMode = "default";
    #   bracketMode = "rainbow";
    #   colorOverrides = { };
    #   customUIColors = { };
    # })

    # Nix
    jnoortheen.nix-ide
    jeff-hykin.better-nix-syntax

    # formulahendry.code-runner
    aaron-bond.better-comments
    dotjoshjohnson.xml
    foxundermoon.shell-format
    # bmalehorn.shell-syntax

    # TOML
    tamasfe.even-better-toml
    redhat.vscode-yaml
    # jeff-hykin.better-dockerfile-syntax


    oderwat.indent-rainbow
    davidanson.vscode-markdownlint
    # evan-buss.font-switcher
    github.vscode-github-actions
    # ms-python.python
    # esbenp.prettier-vscode
    # sumneko.lua

    mkhl.direnv
    ms-vscode-remote.remote-ssh
    pkief.material-product-icons
  ];

  marketPlaceExtensions = (pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
    ### CSS
    {
      name = "color-highlight-css-color-4";
      publisher = "Yunduo";
      version = "1.1.3";
      # sha256 = lib.fakeSha256;
      sha256 = "sha256-2/x078M1wi4/F9aVpHQTgWKdDnEHqXKea+tsNw7YyBo=";
    }
    {
      name = "color-picker";
      publisher = "MarkosTh09";
      version = "1.0.0";
      # sha256 = lib.fakeSha256;
      sha256 = "sha256-28tSGWdtQVu0I34DQBl1CicEqQHP37dS//FH9sTaECY=";
    }

    # {
    #   name = "macos-modern-theme";
    #   publisher = "davidbwaters";
    #   version = "2.3.19";
    #   sha256 = "sha256-/gpGu3vvomQA0TC+TBJkBe2AFWimIyiMM5fndYF8G/A=";
    # }

    ### Icons ###
    {
      name = "simple-icons";
      publisher = "Comdec";
      version = "0.1.6";
      sha256 = "sha256-OSsVdJyG7Mi4ltza40LvmyDZF/hMmVZENfJkaBzVcWw=";
    }

    {
      name = "Mihale";
      publisher = "zeno";
      version = "0.2.0";
      sha256 = "sha256-OSsVdJyG7Mi4ltza40LvmyDZF/hMmVZENfJkaBzVcWw=";
    }

    ### Workspace
    {
      name = "l13-projects";
      publisher = "L13RARY";
      version = "2.0.0";
      sha256 = "sha256-HVlnHzIxRZbTXu0zg9DXUAXaydmQaIt9H4ZYmmrniR0=";
    }

    ### Enable/disable formating button
    {
      name = "vscode-status-bar-format-toggle";
      publisher = "tombonnike";
      version = "3.2.0";
      sha256 = "sha256-MuDOhp6Ur5iwzHjyK7qEVSGOQovfWPwwYJ0Sl/RsIQE=";
    }

    # {
    #   name = "shell-format";
    #   publisher = "foxundermoon";
    #   version = "7.2.5";
    #   # sha256 = lib.fakeSha256;
    #   sha256 = "sha256-kfpRByJDcGY3W9+ELBzDOUMl06D/vyPlN//wPgQhByk=";
    # }

    ### Draw a line between code functions, etc
    {
      name = "separators";
      publisher = "alefragnani";
      version = "2.7.0";
      sha256 = "sha256-ir2qQwhA2cYmJ/K/DDSaTveVnWh8NUZKJN5GXvT2v/E=";
    }

    # {
    #   name = "vscode-thunder-client";
    #   publisher = "rangav";
    #   version = "2.25.5";
    #   # sha256 = lib.fakeSha256;
    #   sha256 = "sha256-uwHsTMi1huo8VhVuAynzGbZbBiEPBSqBOAsz3CCvvgM=";
    # }

    ### Reload Button
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

    ### Themes
    # {
    #   name = "darker-plus-material-red";
    #   publisher = "chireia";
    #   version = "1.0.2";
    #   # sha256 = lib.fakeSha256; ### if you trust
    #   sha256 = "sha256-YT8g6hA4Cs0EGan+d3iIKVh/fZm10/DcOxYiiEXEeYc=";
    # }
    # {
    #   name = "beardedicons";
    #   publisher = "beardedbear";
    #   version = "1.18.0";
    #   sha256 = "sha256-m8utv500Xk6jLI5ndNfiOoPZfyJcLC2XuNwLdC9J+6w=";
    # }
    # {
    #   name = "linux-desktop-file";
    #   publisher = "nico-castell";
    #   version = "0.0.21";
    #   sha256 = "sha256-4qy+2Tg9g0/9D+MNvLSgWUE8sc5itsC/pJ9hcfxyVzQ=";
    # }
    {
      name = "red-theme";
      publisher = "RedCrafter07";
      version = "0.0.4";
      # sha256 = lib.fakeSha256;
      sha256 = "sha256-zGQaQDusiEhuvqGd5AqSpTYKpuaGR2WJr5XpPbESzeU=";
    }
    {
      name = "Codeify";
      publisher = "siyam";
      version = "1.1.2";
      sha256 = "sha256-zGQaQDusiEhuvqGd5AqSpTYKpuaGR2WJr5XpPbESzeU=";
    }
  ]);
in
marketPlaceExtensions ++ packagedExtensions
