{ pkgs, lib ? pkgs.lib, ... }@args:
{
  programs.vscode = {
    userSettings = {
      update.mode = "none";
      window = {
        titleBarStyle = "custom"; # for wayland
        title = "\${rootName}\${separator}\${profileName}\${separator}\${activeEditorShort}";
        menuBarVisibility = "toggle";
        nativeTabs = true;
        commandCenter = false; #disable, just use ctrl + p
        # titleBarStyle = "custom";
        zoomLevel = 1;
        # zoomLevel = 0;
      };
      terminal.integrated = {
        shell.linux = "${pkgs.bash}/bin/bash";
        # shell.linux = "${pkgs.zsh}/bin/zsh";
        # shell.linux = "${pkgs.fish}/bin/fish";
        cursorBlinking = true;
        cursorStyle = "line";
        cursorWidth = 2;
        fontFamily = "'UbuntuMono Nerd Font Mono Regular', 'monospace'";
        fontSize = 15;
        smoothScrolling = true;
        copyOnSelection = true;
        scrollback = 5000;
        showExitAlert = false;
      };

      explorer = {
        sortOrder = "default";
        sortOrderLexicographicOptions = "default";
        incrementalNaming = "smart";
        confirmDragAndDrop = false;
        confirmDelete = false;
        compactFolders = false;
        fileNesting = {
          enabled = true;
        };
      };

      editor = {
        fontFamily = "'JetbrainsMono Nerd Font', 'SauceCodePro Nerd Font Propo Regular Italic', 'Droid Sans Mono'";
        fontLigatures = true;
        scrollbar = {
          horizontal = "auto";
          vertical = "auto";
        };
        rulers = [ "80" "120" ];
        cursorStyle = "line";
        # cursorStyle = "block";
        lineHeight = 1.8;
        suggestSelection = "first";
        inlineSuggest.enabled = true;
        find = {
          autoFindInSelection = "multiline";
        };
        quickSuggestions = {
          comments = "on";
        };
        minimap.renderCharecters = false;
        minimap.maxColumn = 90;
        minimap.autohide = true;
        roundedSelection = true;
        renderWhitespace = "trailing";
        smoothScrolling = true;
        lineNumbers = "on";
        cursorBlinking = "smooth";
        cursorSmoothCaretAnimation = "on";
        cursorSurroundingLines = 2;
        cursorSurroundingLinesStyle = "all";
        cursorWidth = 2;
        tabsize = 2;
        quickSuggestionsdelay = 1;
        formatOnPaste = true;
        formatOnSave = true;
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
          organizeImports = "always";
          fixAll = true;
        };
        suggest.localityBonus = true;
        # wordWrap = "wordWrapColumn";
        wordWrap = "bounded";
        wordWrapColumn = 100;
        wrappingIndent = "indent";
      };

      diffEditor = {
        codeLens = true;
        experimental = {
          showMoves = true;
        };
        hideUnchangedRegions.enabled = true;
      };

      search = {
        smartCase = true;
        followSymlinks = false;
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
        editor = {
          labelFormat = "short";
        };
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
        autoGuessEnconding = true;
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
          "**/*.exe" = true;
          "**/*.o" = true;
          "**/.direnv" = true;
          "**/.factorypath" = true;
        };
      };

      git = {
        allowForcePush = true;
        autofetch = true;
        confirmSync = false;
        enableSmartCommit = true;
        openRepositoryInParentFolders = "always";
      };

      "editor.bracketPairColorization.enabled" = true;
      "editor.fontFamily" = "Fira Code Retina";
      "editor.fontSize" = 16;
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font Mono', 'JetBrainsMono Nerd Font Mono SemiBold'";
      # "terminal.integrated.fontSize" = 15;
      "terminal.integrated.tabs.focusMode" = "singleClick";
      "terminal.integrated.copyOnSelection" = true;
      "terminal.integrated.scrollback" = 5000;
      "terminal.integrated.persistentSessionScrollback" = 200;
      "terminal.integrated.mouseWheelScrollSensitivity" = 2;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "extensions.ignoreRecommendations" = true;
      "files.enableTrash" = false;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      "files.trimTrailingWhitespace" = true;
      "lldb.suppressUpdateNotifications" = true;
      "zenMode.hideLineNumbers" = false;


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
      "security.promptForLocalFileProtocolHandling" = false;
      "update.mode" = "none";
      "breadcrumbs.enabled" = true;
      "update.showReleaseNotes" = false;
      # "vscode-neovim.neovimClean" = true;
      # "vscode-neovim.useCtrlKeysForInsertMode" = false;
      # "window.titleBarStyle" = "custom";
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
