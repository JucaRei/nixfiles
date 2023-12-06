{ pkgs, lib, ... }:
let
nixGLVulkanMesaWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
        wrapped_bin=$out/bin/$(basename $bin)
        echo "${lib.getExe pkgs.nixgl.nixGLIntel} ${
          lib.getExe pkgs.nixgl.nixVulkanIntel
        } $bin \$@" > $wrapped_bin
        chmod +x $wrapped_bin
      done
    '';
in {
  programs.vscode = {
    enable = true;
    # package = pkgs.unstable.vscode;
    # package = pkgs.vscodium-fhs;
    package = nixGLVulkanMesaWrap pkgs.unstable.vscode.override {
      commandLineArgs = builtins.concatStringsSep " " [
        "--enable-wayland-ime"
        "--ozone-platform-hint=auto"
      ];
    };

    mutableExtensionsDir = true;
    enableUpdateCheck = false;

    extensions =
      with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        brettm12345.nixfmt-vscode
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

    userSettings = {
      update.mode = "none";
      window = {
        title = "\${rootName}\${separator}\${profileName}\${separator}\${activeEditorShort}";
        menuBarVisibility = "toggle";
        nativeTabs = true;
        # titleBarStyle = "custom";
        # zoomLevel = 1;
        zoomLevel = 0;
      };
      terminal.integrated = {
        shell.linux = "${pkgs.bash}/bin/bash";
        # shell.linux = "${pkgs.zsh}/bin/zsh";
        # shell.linux = "${pkgs.fish}/bin/fish";
        cursorBlinking = true;
        cursorStyle = "line";
        cursorWidth = 2;
        fontFamily = "'UbuntuMono Nerd Font Mono Regular', 'monospace'";
        fontSize = 16;
        smoothScrolling = true;
        copyOnSelection = true;
        scrollback = 5000;
      };

      explorer = {
        sortOrder = "default";
        sortOrderLexicographicOptions = "default";
        incrementalNaming = "smart";
        confirmDragAndDrop = false;
        confirmDelete = true;
      };



      editor = {
        fontFamily = "'SauceCodePro Nerd Font Propo Regular Italic', 'Droid Sans Mono','JetbrainsMono Nerd Font'";
        fontLigatures = true;
        scrollbar = {
          horizontal = "auto";
          vertical = "auto";
        };
        cursorStyle = "line";
        # cursorStyle = "block";
        lineHeight = 1.4;
        inlineSuggest.enabled = true;
        minimap.renderCharecters = false;
        minimap.maxColumn = 80;
        minimap.autohide = true;
        roundedSelection = true;
        renderWhitespace = "trailing";
        smoothScrolling = true;
        lineNumbers = "on";
        cursorBlinking = "smooth";
        cursorSmoothCaretAnimation = "on";
        cursorWidth = 2;
        tabsize = 2;
        quickSuggestionsdelay = 1;
        formatOnSave = true;
        formatOnPaste = true;
        formatOnType = false;
        guides = {
          bracketPairs = true;
          indentation = true;
        };
        bracketPairColorization = {
          enabled = true;
          independentColorPoolPerBracketType = true;
        };
        largeFileOptimizations = true;
        codeActionsOnSave.source = {
          organizeImports = true;
          #   fixAll.eslint = true;
        };
      };

      search = {
        smartCase = true;
        sortOrder = "default";
        searchEditor.doubleClickBehaviour = "goToLocation";
      };

      docker = {
        environment = {
          "DOCKER_HOST" = "unix:///run/user/1000/podman/podman.sock";
        };
        "composeCommand" = "podman-compose";
        "dockerPath" = "${pkgs.podman}/bin/podman";
      };

      dev = {
        containers = {
          # dockerPath = "${pkgs.podman}/bin/podman";
          runArgs = [ "--userns=keep-id" ];
          # containerUser = "juca";
          # updateRemoteUserUID = true;
          containerEnv = {
            "HOME" = "home/node";
          };
        };
      };
      workbench = {
        iconTheme = "vscode-icons";
        # iconTheme = "bearded-icons";
        # colorTheme = "GitHub Dark"; # Material Theme Ocean High Contrast
        colorTheme = "RedCrafter07 Theme";
        # colorTheme = "Rainbow Extended";
        list.smoothScrolling = true;
        # productIconTheme = "material-product-icons";
        productIconTheme = "bootstrap-product-icons";
        # productIconTheme = "tabler-icons";
        smoothScrolling = true;
        tree = {
          indent = 4;
        };
        settings = {
          editor = "ui";
        };
      };

      ocamlformat-vscode-extension = {
        customOcamlformatPath = "ocamlformat";
        ocamlformatOption = "--enable-outside-detected-project,--break-cases = fit-or-vertical,--cases-exp-indent=4,--if-then-else=k-r,--type-decl-indent=4";
      };

      #jupyter.widgetScriptSources = [ "jsdelivr.com" "unpkg.com" ]; # required by qgrid
      jupyter.alwaysTrustNotebooks = true;
      rust-client.rustupPath = "${pkgs.rustup}/bin/rustup";
      latex-workshop.view.pdf.viewer = "tab";
      cmake.configureOnOpen = false;
      python.formatting.provider = "black";
      #"[ocaml]" = {
      #  editor.defaultFormatter = "hoddy3190.ocamlformat-vscode-extension";
      #};
      "[css]" = { editor.defaultFormatter = "MikeBovenlander.formate"; };
      files = {
        autoSave = "afterDelay";
        eol = "\n";
        insertFinalNewline = true;
        trimTrailingWhitespace = true;

        exclude = {
          "**/.git" = true;
          "**/.svn" = true;
          "**/.hg" = true;
          "**/CVS" = true;
          "**/.DS_Store" = true;
          "**/Thumbs.db" = true;
          "**/*.olean" = true;
          "**/.project" = true;
          "**/.settings" = true;
          "**/.classpath" = true;
          "**/.direnv" = true;
          "**/.factorypath" = true;
        };
      };

      git = {
        autofetch = true;
        confirmSync = false;
        enableSmartCommit = true;
      };

      window = {
        titleBarStyle = "custom";
      };

      "editor.bracketPairColorization.enabled" = true;
      "editor.fontFamily" = "Fira Code Retina";
      "editor.fontSize" = 21;
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Mono', 'JetBrainsMono Nerd Font Mono SemiBold'";
      "terminal.integrated.fontSize" = 17;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "extensions.ignoreRecommendations" = true;
      "files.enableTrash" = false;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      "files.trimTrailingWhitespace" = true;
      "lldb.suppressUpdateNotifications" = true;

      markdown = {
        preview.typographer = true;
        extension.print.theme = "dark";
      };
      "markdownlint.config" = {
        "MD024"."siblings_only" = true;
        "MD028" = false;
        "MD040" = false;
        "MD041" = false;
      };

      # Nil
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings"."nil"."diagnostics"."ignored" = [ "unused_binding" "unused_with" ];
      "nix.serverSettings"."nil"."formatting"."command" = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];

      # Nixd
      # nix = {
      #   serverPath = "${pkgs.unstable.nixd}/bin/nixd";
      #   serverSettings = {
      #     nixd = {
      #       eval = { };
      #       formatting = {
      #         command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
      #       };
      #       optios = {
      #         enable = true;
      #         target = {
      #           arg = [ ];
      #           # NixOS options
      #           installable = "<flakeref>#nixosConfigurations.<name>.options";

      #           # Home-manager options
      #           # installable = "<flakeref>#homeConfigurations.<name>.options";
      #         };
      #       };
      #     };
      #   };
      # };

      "[nix]" = {
        editor.defaultFormatter = "jnoortheen.nix-ide";
      };
      "security.workspace.trust.enabled" = false;
      "update.mode" = "none";
      "update.showReleaseNotes" = false;
      # "vscode-neovim.neovimClean" = true;
      # "vscode-neovim.useCtrlKeysForInsertMode" = false;
      "window.menuBarVisibility" = "toggle";
      "window.titleBarStyle" = "custom";
      "workbench.enableExperiments" = false;
      # "workbench.colorTheme" = "Bearded Theme Monokai Stone";
      "workbench.settings.enableNaturalLanguageSearch" = false;
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;

      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
    };
  };


  # xdg.desktopEntries = {
  #   "code" = {
  #     categories = [ "Utility" "TextEditor" "Development" "IDE" ];
  #     comment = "Code Editing. Redefined.";
  #     exec = "${pkgs.vscode}/bin/code %F";
  #     genericName = "Text Editor";
  #     icon = "code";
  #     mimeType = [ "text/plain" "inode/directory" ];
  #     name = "Visual Studio Code";
  #     startupNotify = true;
  #     type = "Application";
  #   };
  # };
}
