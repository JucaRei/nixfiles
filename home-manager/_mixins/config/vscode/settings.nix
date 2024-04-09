{ pkgs, lib ? pkgs.lib, ... }:
let
  _ = lib.getExe;
  terminal = "${_ pkgs.fish}";
in
{
  ##############
  ### Update ###
  ##############
  "update.mode" = "none";
  "update.showReleaseNotes" = true;

  ##############
  ### Window ###
  ##############
  "window.titleBarStyle" = "custom"; # Wayland
  "window.title" = "\${rootName}\${separator}\${profileName}\${separator}\${activeEditorShort}";
  "window.menuBarVisibility" = "toggle";
  # "window.nativeTabs" = "true";
  "window.commandCenter" = false; # disable, just use ctrl + p
  "window.zoomLevel" = 0.3;
  "window.density.editorTabHeight" = "compact";

  ################
  ### Terminal ###
  ################
  # "terminal.integrated.shell.linux" = "${pkgs.bash}/bin/bash";
  # "terminal.integrated.shell.linux" = "${pkgs.zsh}/bin/zsh";
  "terminal.integrated.shell.linux" = "${terminal}";
  "terminal.integrated.cursorBlinking" = true;
  "terminal.integrated.cursorStyle" = "line";
  "terminal.integrated.cursorWidth" = 1.8;
  "terminal.integrated.fontFamily" = "'UbuntuMono Nerd Font Mono Regular', 'monospace'";
  "terminal.integrated.smoothScrolling" = true;
  "terminal.integrated.fontSize" = 16;
  "terminal.integrated.scrollback" = 5000;
  "terminal.integrated.copyOnSelection" = true;
  "terminal.integrated.showExitAlert" = false;
  "terminal.integrated.tabs.focusMode" = "singleClick";
  "terminal.integrated.persistentSessionScrollback" = 200;
  "terminal.integrated.mouseWheelScrollSensitivity" = 2;

  ################
  ### Explorer ###
  ################
  "explorer.sortOrder" = "default";
  "explorer.sortOrderLexicographicOptions" = "default";
  "explorer.incrementalNaming" = "smart";
  "explorer.confirmDragAndDrop" = false;
  "explorer.confirmDelete" = false;
  "explorer.compactFolders" = false;
  "explorer.fileNesting.enabled" = true;

  #######################
  ### Editor Settings ###
  #######################
  "editor.fontFamily" = "'JetbrainsMono Nerd Font SemiBold Italic', 'SauceCodePro Nerd Font Propo Regular Italic', 'Droid Sans Mono'";
  "editor.fontLigatures" = true;
  "editor.bracketPairColorization.enabled" = true;
  "editor.fontSize" = 18;
  "editor.fontVariations" = true;
  "editor.fontWeight" = 500;
  "editor.scrollbar.horizontal" = "auto";
  "editor.scrollbar.vertical" = "auto";
  "editor.rulers" = [ 80 120 ];
  "editor.cursorStyle" = "line";
  "editor.lineHeight" = 1.6;
  "editor.suggestSelection" = "first";
  "editor.inlineSuggest.enabled" = true;
  "editor.find.autoFindInSelection" = "multiline";
  "editor.quickSuggestions.comments" = "on";
  "editor.minimap.renderCharecters" = false;
  "editor.minimap.maxColumn" = 100;
  "editor.minimap.autohide" = true;
  "editor.roundedSelection" = true;
  "editor.renderWhitespace" = "trailing";
  "editor.smoothScrolling" = true;
  "editor.lineNumbers" = "on";
  "editor.cursorBlinking" = "smooth";
  "editor.cursorSmoothCaretAnimation" = "on";
  "editor.cursorSurroundingLines" = 1.2;
  "editor.cursorSurroundingLinesStyle" = "all";
  "editor.cursorWidth" = 1.6;
  "editor.tabsize" = 1.5;
  "editor.quickSuggestionsdelay" = 1;
  "editor.formatOnPaste" = true;
  "editor.formatOnSave" = true;
  "editor.guides.bracketPairs" = true;
  "editor.guides.indentation" = true;
  "editor.guides.bracketPairColorization.enabled" = true;
  "editor.guides.bracketPairColorization.independentColorPoolPerBracketType" =
    true;
  "editor.largeFileOptimizations" = true;
  "editor.codeActionsOnSave.source.organizeImports" = "always";
  "editor.codeActionsOnSave.source.fixAll" = true;
  "editor.suggest.localityBonus" = true;
  "editor.wordWrap" = "bounded";
  "editor.wordWrapColumn" = 120;
  "editor.wrappingIndent" = "indent";
  ### Diff
  "editor.diffEditor.codeLens" = true;
  "editor.diffEditor.experimental.showMoves" = true;
  "editor.diffEditor.hideUnchangedRegions.enabled" = true;
  ### Search
  "editor.search.smartCase" = true;
  "editor.search.followSymlinks" = false;
  "editor.search.sortOrder" = "default";
  "editor.search.searchEditor.doubleClickBehaviour" = "goToLocation";

  #######################
  ### Podman | Docker ###
  #######################
  # "docker.environment" = {
  #   "DOCKER_HOST" = "unix:///run/user/1000/podman/podman.sock";
  # };
  # "docker.composeCommand" = "podman-compose";
  # "docker.dockerPath" = "${_ pkgs.podman}";

  ######################
  ### Dev Containers ###
  ######################
  # "dev.containers.runArgs" = [ "--userns=keep-id" ];
  # "dev.containers.containerEnv" = { "HOME" = "home/node"; };

  #################
  ### Workbench ###
  #################
  "workbench.editor.labelFormat" = "short";
  "workbench.enableExperiments" = true;
  # "workbench.colorTheme" = "Bearded Theme Monokai Stone";
  # "workbench.colorTheme" = "GitHub Dark";
  # "workbench.colorTheme" = "Material Theme Ocean High Contrast";
  "workbench.colorTheme" = "RedCrafter07 Theme";
  # "workbench.iconTheme" = "vscode-icons";
  "workbench.iconTheme" = "bearded-icons";
  "workbench.settings.enableNaturalLanguageSearch" = true;
  "workbench.list.smoothScrolling" = true;
  "workbench.smoothScrolling" = true;
  "workbench.productIconTheme" = "macos-modern";
  "workbench.tree.indent" = 4;
  "workbench.settings.editor" = "ui";

  ######################
  ### Files Settings ###
  ######################
  "files.autoSave" = "afterDelay";
  "files.autoGuessEncoding" = true;
  "files.eol" = "\n";
  "files.insertFinalNewline" = true;
  "files.enableTrash" = false;
  "files.trimFinalNewlines" = true;
  "files.trimTrailingWhitespace" = true;
  "files.exclude" = {
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

  ####################
  ### Git Settings ###
  ####################
  "git.allowForcePush" = true;
  "git.autofetch" = true;
  "git.confirmSync" = true;
  "git.enableSmartCommit" = true;
  "git.openRepositoryInParentFolders" = "always";

  ################
  ### Markdown ###
  ################
  "markdown.preview.typographer" = true;
  "markdown.extension.print.theme" = "dark";
  "markdownlint.config" = {
    "MD024"."siblings_only" = true;
    "MD028" = false;
    "MD040" = false;
    "MD041" = false;
  };

  ##################
  ### Nix Config ###
  ##################
  "nix.enableLanguageServer" = true;
  "nix.serverPath" = "${_ pkgs.nil}";
  # "nix.serverPath" = "${pkgs.unstable.nixd}/bin/nixd";
  "nix.formatterPath" = "${_ pkgs.nixpkgs-fmt}";
  "nix.serverSettings" = {
    # "nixd" = {
    #   "eval" = { };
    #   "formatting" = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
    #   "options" = {
    #     "enable" = true;
    #     "target" = {
    #       "arg" = [ ];
    #       # NixOS options
    #       #           installable = "<flakeref>#nixosConfigurations.<name>.options";
    #       # Home-manager options
    #       #           # installable = "<flakeref>#homeConfigurations.<name>.options";
    #     };
    #   };
    # };
    "nil" = {
      "diagnostics" = { "ignored" = [ "unused_binding" "unused_with" ]; };
      "formatting" = {
        "command" = [ "${_ pkgs.nixpkgs-fmt}" ];
        # "command" = [ "${pkgs.nixfmt}/bin/nixfmt" ];
      };
    };
  };
  "nix" = {
    "editor.defaultFormatter" = "jnoortheen.nix-ide";
  };

  ################
  ### Security ###
  ################
  "security.workspace.trust.enabled" = false;
  "security.promptForLocalFileProtocolHandling" = false;

  ##############
  ### Others ###
  ##############
  # "rust-client.rustupPath" = "${pkgs.rustup}/bin/rustup";
  # "jupyter.alwaysTrustNotebooks" = true;
  # "jupyter.widgetScriptSources" = [ "jsdelivr.com" "unpkg.com" ]; # required by qgrid
  # "ocamlformat-vscode-extension" =
  #   {
  #     "customOcamlformatPath" = "ocamlformat";
  #     "ocamlformatOption" = "--enable-outside-detected-project,--break-cases = fit-or-vertical,--cases-exp-indent=4,--if-then-else=k-r,--type-decl-indent=4";
  #   };
  # "latex-workshop.view.pdf.viewer" = "tab";
  # "cmake.configureOnOpen" = false;
  # "python.formatting.provider" = "black";
  #"[ocaml]" = {
  #  "editor.defaultFormatter" = "hoddy3190.ocamlformat-vscode-extension";
  #};
  # "[css]" = { "editor.defaultFormatter" = "MikeBovenlander.formate"; };
  "extensions.autoCheckUpdates" = false;
  "extensions.autoUpdate" = false;
  "extensions.ignoreRecommendations" = true;
  "lldb.suppressUpdateNotifications" = true;
  "zenMode.hideLineNumbers" = false;
  # "breadcrumbs.enabled" = true;

  ##################
  ### Javascript ###
  ##################
  # "[typescriptreact]" = {
  #   "editor.defaultFormatter" = "esbenp.prettier-vscode";
  # };
  # "[typescript]" = {
  #   "editor.defaultFormatter" = "esbenp.prettier-vscode";
  # };
}
