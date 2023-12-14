{ pkgs, ... }: {
  home = {
    packages = with pkgs;[
      # alejandra
      cachix
      any-nix-shell
      cached-nix-shell
      deadnix
      nix-bash-completions
      nix-index
      nix-melt
      nix-prefetch-git
      nix-du
      nixpkgs-fmt
      nurl
      nil
      # nixd
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
