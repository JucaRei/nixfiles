{ pkgs, lib, ... }: {
  programs.vscode = {
    enable = true;
    # package = pkgs.unstable.vscode;
    # package = pkgs.vscodium-fhs;
    package = pkgs.vscodium.override {
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
      ]
      ++ pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
        # {
        #   name = "vsc-darker-plus-material-red";
        #   publisher = "chireia";
        #   version = "1.0.2";
        #   sha256 = lib.fakeSha256; ### if you trust
        #   # sha256 = "sha256-LTgJDeNZoBi/QjHcal7QUMmQnNPjupi+K7l/EkFgfwI=";
        # }
        #   # {
        #   #   name = "beardedicons";
        #   #   publisher = "beardedbear";
        #   #   version = "1.13.2";
        #   #   sha256 = "sha256-PpIut/yhUNK1eTPRvVXONt06TOXpoGgmd6lrhFdADRQ";
        #   # }
        #   # {
        #   #   name = "linux-desktop-file";
        #   #   publisher = "nico-castell";
        #   #   version = "0.0.21";
        #   #   sha256 = "sha256-4qy+2Tg9g0/9D+MNvLSgWUE8sc5itsC/pJ9hcfxyVzQ=";
        #   # }
        #   {
        #     name = "pork-and-beans";
        #     publisher = "HighSpeedDirt";
        #     version = "0.9.2";
        #     # sha256 = lib.fakeSha256;
        #     sha256 = "sha256-wIVQmlh4Dvka/O4l5PCSb4fv8iKgZDzXVEMShfjlQfY=";
        #   }
        #   {
        #     name = "red-theme";
        #     publisher = "RedCrafter07";
        #     version = "0.0.2";
        #     # sha256 = lib.fakeSha256;
        #     sha256 = "sha256-GbNvoXeYpLMTyDze82qckTrepMJDE2I0RcilGKVGhdg=";
        #   }
        #   {
        #     name = "gamberetti-reborn-theme";
        #     publisher = "dSyncro";
        #     version = "1.0.0";
        #     # sha256 = lib.fakeSha256;
        #     sha256 = "sha256-cRiwx6ELRnHIqobBwYkrZXnptue/+M9bDKvonhQ8hj4=";
        #   }
        #   {
        #     name = "catppuccin-perfect-icons";
        #     publisher = "thang-nm";
        #     # sha256 = lib.fakeSha256;
        #     sha256 = "sha256-S9s+CQWu3ADRW0J7BPxTTypwMOmpzmdeXcZcSVHXPyU=";
        #   }
        #   {
        #     name = "Rainbow Theme";
        #     publisher = "Dreamyplayer";
        #     # sha256 = lib.fakeSha256;
        #     sha256 = "sha256-/Glcaj8K28ccB16WLJqs5+l5j3ROQnRli6oooVIvLqg=";
        #   }
        #   {
        #     publisher = "zguolee";
        #     name = "tabler-icons";
        #     version = "0.2.2";
        #     sha256 = "UxMjXwfL9YMb7nGH41LoAu9R3b4dWdK66+w0tfGy8Lk=";
        #   }
      ];

    userSettings = {
      update.mode = "none";
      window = {
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
      };

      editor = {
        fontFamily = "'SauceCodePro Nerd Font Propo Regular Italic', 'Droid Sans Mono','JetbrainsMono Nerd Font'";
        fontLigatures = true;
        cursorStyle = "line";
        # cursorStyle = "block";
        lineHeight = 1.4;
        inlineSuggest.enabled = true;
        minimap.renderCharecters = false;
        minimap.maxColumn = 80;
        minimap.autohide = true;
        renderWhitespace = "trailing";
        smoothScrolling = true;
        lineNumbers = "on";
        cursorBlinking = "smooth";
        cursorSmoothCaretAnimation = "on";
        cursorWidth = 2;
        formatOnSave = true;
        guides = {
          bracketPairs = true;
          indentation = true;
        };
        bracketPairColorization = {
          enabled = true;
          independentColorPoolPerBracketType = true;
        };
        largeFileOptimizations = false;
        codeActionsOnSave.source = {
          organizeImports = true;
          #   fixAll.eslint = true;
        };
      };

      docker = {
        environment = {
          "DOCKER_HOST" = "unix:///run/user/1000/podman/podman.sock";
        };
        "composeCommand" = "podman compose";
        "dockerPath" = "/nix/store/5qk52lw1lvsb7znpn500zhwm5wsrvhsk-system-path/bin/podman";
      };

      workbench = {
        iconTheme = "catppuccin-perfect-dark";
        # colorTheme = "GitHub Dark"; # Material Theme Ocean High Contrast
        # colorTheme = "Gamberetti Reborn (Dark)";
        list.smoothScrolling = true;
        colorTheme = "Rainbow Extended";
        # productIconTheme = "material-product-icons";
        smoothScrolling = true;
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
      "markdownlint.config" = {
        "MD024"."siblings_only" = true;
        "MD028" = false;
        "MD040" = false;
        "MD041" = false;
      };
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings"."nil"."diagnostics"."ignored" = [ "unused_binding" "unused_with" ];
      "nix.serverSettings"."nil"."formatting"."command" = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
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
      "workbench.colorTheme" = "Darker+ Material Red";
      "workbench.settings.enableNaturalLanguageSearch" = false;
      "workbench.productIconTheme" = "Tabler";
      "workbench.startupEditor" = "none";
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
