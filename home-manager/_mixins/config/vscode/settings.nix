args@{ pkgs, lib ? pkgs.lib, ... }: {
  programs.vscode = {
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
        formatOnSaveMode = "modificationsIfAvailable";
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
      # "nix.enableLanguageServer" = true;
      # "nix.serverPath" = "${pkgs.nil}/bin/nil";
      # "nix.serverSettings"."nil"."diagnostics"."ignored" = [ "unused_binding" "unused_with" ];
      # "nix.serverSettings"."nil"."formatting"."command" = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];

      nix = {
        enableLanguageServer = true;
        serverPath = "${pkgs.nil}/bin/nil";
        formatterPath = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
        "serverSettings" = {
          nil = {
            diagnostics = {
              ignored = [ "unused_binding" "unused_with" ];
            };
            formatting = {
              command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
            };
          };
        };
      };
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };

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

      "security.workspace.trust.enabled" = false;
      "update.mode" = "none";
      "update.showReleaseNotes" = false;
      # "vscode-neovim.neovimClean" = true;
      # "vscode-neovim.useCtrlKeysForInsertMode" = false;
      "window.menuBarVisibility" = "toggle";
      "window.titleBarStyle" = "custom";
      "workbench.enableExperiments" = true;
      # "workbench.colorTheme" = "Bearded Theme Monokai Stone";
      "workbench.settings.enableNaturalLanguageSearch" = true;
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


}
