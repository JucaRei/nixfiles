{ pkgs, ... }: {
  home = {
    packages = with pkgs;[
      # alejandra
      any-nix-shell
      cached-nix-shell
      deadnix
      nix-bash-completions
      nix-index
      nix-du
      nixpkgs-fmt
      nurl
      nil
      # rnix-lsp
      statix
    ];
  };

  # programs = {
  #   nix-index = {
  #     enable = true;
  #     enableBashIntegration = true;
  #     enableFishIntegration = true;
  #     enableZshIntegration = true;
  #   };
  # };
}
