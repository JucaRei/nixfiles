{ pkgs, ... }:
let
  packagedExtensions = with pkgs.unstable.vscode-extensions; [
    jnoortheen.nix-ide
    oderwat.indent-rainbow
    formulahendry.code-runner
    davidanson.vscode-markdownlint
    tamasfe.even-better-toml
    editorconfig.editorconfig
    redhat.vscode-yaml
    ms-python.python
    esbenp.prettier-vscode
    mkhl.direnv
    sumneko.lua
    ms-vscode-remote.remote-ssh
  ];

  marketPlaceExtensions = (pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
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
      name = "l13-projects";
      publisher = "L13RARY";
      version = "1.1.1";
      sha256 = "sha256-HVlnHzIxRZbTXu0zg9DXUAXaydmQaIt9H4ZYmmrniR0=";
    }
    {
      name = "vscode-status-bar-format-toggle";
      publisher = "tombonnike";
      version = "3.2.0";
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
      version = "2.7.0";
      sha256 = "sha256-JTFD6TGt4C3ctm+2ckTzqje2M/SiK7xshr1Hf9rQkFA=";
    }
    {
      name = "vscode-thunder-client";
      publisher = "rangav";
      version = "2.25.5";
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
  ]);
in
marketPlaceExtensions ++ packagedExtensions
