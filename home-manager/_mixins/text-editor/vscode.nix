{ pkgs, lib, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
    # package = pkgs.vscodium-fhs;
    # package = pkgs.vscodium.override {
    #   commandLineArgs = builtins.concatStringsSep " " [
    #     "--enable-wayland-ime"
    #     "--ozone-platform-hint=auto"
    #   ];
    # };
    mutableExtensionsDir = false;
    enableUpdateCheck = false;

    extensions =
      (with with pkgs; [ vscode-extensions ]; [
        jnoortheen.nix-ide
        brettm12345.nixfmt-vscode
        oderwat.indent-rainbow
        catppuccin.catppuccin-vsc-icons
        formulahendry.code-runner
        davidanson.vscode-markdownlint
        editorconfig.editorconfig
      ] ++ pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vsc-darker-plus-material-red";
          publisher = "chireia";
          version = "1.0.2";
          # sha256 = lib.fakeSha256;  ### if you trust
          sha256 = "sha256-LTgJDeNZoBi/QjHcal7QUMmQnNPjupi+K7l/EkFgfwI=";
        }
        {
          name = "pork-and-beans";
          publisher = "HighSpeedDirt";
          version = "0.9.2";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-wIVQmlh4Dvka/O4l5PCSb4fv8iKgZDzXVEMShfjlQfY=";
        }
        {
          name = "red-theme";
          publisher = "RedCrafter07";
          version = "0.0.2";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-GbNvoXeYpLMTyDze82qckTrepMJDE2I0RcilGKVGhdg=";
        }
        {
          name = "gamberetti-reborn-theme";
          publisher = "dSyncro";
          version = "1.0.0";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-cRiwx6ELRnHIqobBwYkrZXnptue/+M9bDKvonhQ8hj4=";
        }
        {
          name = "catppuccin-perfect-icons";
          publisher = "thang-nm";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-S9s+CQWu3ADRW0J7BPxTTypwMOmpzmdeXcZcSVHXPyU=";
        }
        {
          name = "Rainbow Theme";
          publisher = "Dreamyplayer";
          # sha256 = lib.fakeSha256;
          sha256 = "sha256-/Glcaj8K28ccB16WLJqs5+l5j3ROQnRli6oooVIvLqg=";
        }
        {
          publisher = "zguolee";
          name = "tabler-icons";
          version = "0.2.2";
          sha256 = "UxMjXwfL9YMb7nGH41LoAu9R3b4dWdK66+w0tfGy8Lk=";
        }
      ]);

    #     Saikumarchinna.rainbow

    userSettings = {
      update.mode = "none";
      window.zoomLevel = 0;

      # terminal.integrated.shell.linux = "${pkgs.zsh}/bin/zsh";
      # terminal.integrated.shell.linux = "${pkgs.fish}/bin/fish";
      terminal.integrated.shell.linux = "${pkgs.bash}/bin/bash";
      editor = {
        fontFamily = "'SauceCodePro Nerd Font Propo Regular Italic', 'Droid Sans Mono','JetbrainsMono Nerd Font'";
        fontLigatures = true;
        cursorBlinking = "expand";
        cursorStyle = "line";
        # cursorStyle = "block";
        lineHeight = 2.3;
        inlineSuggest.enabled = true;
        minimap.renderCharecters = false;
        minimap.maxColumn = 80;
        minimap.autohide = true;
        bracketPairColorization.enabled = true;
        renderWhitespace = "trailing";
      };

      workbench = {
        iconTheme = "catppuccin-perfect-dark";
        # colorTheme = "GitHub Dark"; # Material Theme Ocean High Contrast
        # colorTheme = "Gamberetti Reborn (Dark)";
        colorTheme = "Rainbow Extended";
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
      window.menuBarVisibility = "toggle";
      files.exclude = {
        "**/.git" = true;
        "**/.svn" = true;
        "**/.hg" = true;
        "**/CVS" = true;
        "**/.DS_Store" = true;
        "**/Thumbs.db" = true;
        "**/*.olean" = true;
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
      "workbench.colorTheme" = "Bearded Theme Monokai Stone";
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
}


