{ mkShell, pkgs, ... }:
mkShell {
  packages = with pkgs; [
    nodePackages."@angular/cli"
    nodejs-18_x
    pnpm
    vimPlugins.nvim-treesitter-parsers.angular
    vscode-extensions.angular.ng-template
    yarn

    figlet
    lolcat
  ];

  shellHook = ''

    echo "🔨 Angular DevShell" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300


  '';
}
